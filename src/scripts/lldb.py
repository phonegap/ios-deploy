import time
import os
import sys
import shlex
import lldb

listener = None

def connect_command(debugger, command, result, internal_dict):
    # These two are passed in by the script which loads us
    connect_url = internal_dict['fruitstrap_connect_url']
    error = lldb.SBError()
    
    # We create a new listener here and will use it for both target and the process.
    # It allows us to prevent data races when both our code and internal lldb code
    # try to process STDOUT/STDERR messages
    global listener
    listener = lldb.SBListener('iosdeploy_listener')
    
    listener.StartListeningForEventClass(debugger,
                                            lldb.SBTarget.GetBroadcasterClassName(),
                                            lldb.SBProcess.eBroadcastBitStateChanged | lldb.SBProcess.eBroadcastBitSTDOUT | lldb.SBProcess.eBroadcastBitSTDERR)
    
    process = lldb.target.ConnectRemote(listener, connect_url, None, error)

    # Wait for connection to succeed
    events = []
    state = (process.GetState() or lldb.eStateInvalid)
    while state != lldb.eStateConnected:
        event = lldb.SBEvent()
        if listener.WaitForEvent(1, event):
            state = process.GetStateFromEvent(event)
            events.append(event)
        else:
            state = lldb.eStateInvalid

    # Add events back to queue, otherwise lldb freezes
    for event in events:
        listener.AddEvent(event)

def run_command(debugger, command, result, internal_dict):
    device_app = internal_dict['fruitstrap_device_app']
    args = command.split('--',1)
    error = lldb.SBError()
    lldb.target.modules[0].SetPlatformFileSpec(lldb.SBFileSpec(device_app))
    args_arr = []
    if len(args) > 1:
        args_arr = shlex.split(args[1])
    args_arr = args_arr + shlex.split('{args}')

    launchInfo = lldb.SBLaunchInfo(args_arr)
    global listener
    launchInfo.SetListener(listener)
    
    #This env variable makes NSLog, CFLog and os_log messages get mirrored to stderr
    #https://stackoverflow.com/a/39581193 
    launchInfo.SetEnvironmentEntries(['OS_ACTIVITY_DT_MODE=enable'], True)

    lldb.target.Launch(launchInfo, error)
    if error.Fail():
        if ': Locked' in str(error):
            print('\\nDevice Locked\\n')
        else:
            print(str(error))
        #force exit to make sure autoexit or safequit don't end up waiting forever
        os._exit({exitcode_error})

def safequit_command(debugger, command, result, internal_dict):
    process = lldb.target.process
    state = process.GetState()
    if state == lldb.eStateRunning:
        process.Detach()
        os._exit(0)
    elif state > lldb.eStateRunning:
        os._exit(state)
    else:
        print('\\nApplication has not been launched\\n')
        os._exit(1)

def autoexit_command(debugger, command, result, internal_dict):
    global listener
    process = lldb.target.process

    appOutput = open('{app_output}', 'w') if '{app_output}' else None
    detectDeadlockTimeout = {detect_deadlock_timeout}
    printBacktraceTime = time.time() + detectDeadlockTimeout if detectDeadlockTimeout > 0 else None

    # This line prevents internal lldb listener from processing STDOUT/STDERR messages. Without it, an order of log writes is incorrect sometimes
    debugger.GetListener().StopListeningForEvents(process.GetBroadcaster(), lldb.SBProcess.eBroadcastBitSTDOUT | lldb.SBProcess.eBroadcastBitSTDERR )

    event = lldb.SBEvent()

    def ProcessSTDOUT():
        stdout = process.GetSTDOUT(1024)
        while stdout:
            if appOutput:
                appOutput.write(stdout)
            sys.stdout.write(stdout)
            stdout = process.GetSTDOUT(1024)

    def ProcessSTDERR():
        stderr = process.GetSTDERR(1024)
        while stderr:
            if appOutput:
                appOutput.write(stderr)
            sys.stdout.write(stderr)
            stderr = process.GetSTDERR(1024)

    def Exit(exitcode):
        ProcessSTDOUT()
        ProcessSTDERR()
        if appOutput:
            appOutput.close()
        os._exit(exitcode)

    while True:
        if listener.WaitForEvent(1, event) and lldb.SBProcess.EventIsProcessEvent(event):
            state = lldb.SBProcess.GetStateFromEvent(event)
            type = event.GetType()
        
            if type & lldb.SBProcess.eBroadcastBitSTDOUT:
                ProcessSTDOUT()
        
            if type & lldb.SBProcess.eBroadcastBitSTDERR:
                ProcessSTDERR()
    
        else:
            state = process.GetState()

        if state == lldb.eStateExited:
            sys.stdout.write( '\\nPROCESS_EXITED\\n' )
            Exit(process.GetExitStatus())
        elif printBacktraceTime is None and state == lldb.eStateStopped:
            sys.stdout.write( '\\nPROCESS_STOPPED\\n' )
            debugger.HandleCommand('bt')
            Exit({exitcode_app_crash})
        elif state == lldb.eStateCrashed:
            sys.stdout.write( '\\nPROCESS_CRASHED\\n' )
            debugger.HandleCommand('bt')
            Exit({exitcode_app_crash})
        elif state == lldb.eStateDetached:
            sys.stdout.write( '\\nPROCESS_DETACHED\\n' )
            Exit({exitcode_app_crash})
        elif printBacktraceTime is not None and time.time() >= printBacktraceTime:
            printBacktraceTime = None
            sys.stdout.write( '\\nPRINT_BACKTRACE_TIMEOUT\\n' )
            debugger.HandleCommand('process interrupt')
            debugger.HandleCommand('bt all')
            debugger.HandleCommand('continue')
            printBacktraceTime = time.time() + 5
