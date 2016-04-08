import lldb
import os
import sys
import shlex

def connect_command(debugger, command, result, internal_dict):
    # These two are passed in by the script which loads us
    connect_url = internal_dict['fruitstrap_connect_url']
    error = lldb.SBError()

    process = lldb.target.ConnectRemote(lldb.target.GetDebugger().GetListener(), connect_url, None, error)

    # Wait for connection to succeed
    listener = lldb.target.GetDebugger().GetListener()
    listener.StartListeningForEvents(process.GetBroadcaster(), lldb.SBProcess.eBroadcastBitStateChanged)
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
    lldb.target.Launch(lldb.SBLaunchInfo(shlex.split(args[1] and args[1] or '{args}')), error)
    lockedstr = ': Locked'
    if lockedstr in str(error):
       print('\\nDevice Locked\\n')
       os._exit(254)
    else:
       print(str(error))

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
    process = lldb.target.process
    listener = debugger.GetListener()
    listener.StartListeningForEvents(process.GetBroadcaster(), lldb.SBProcess.eBroadcastBitStateChanged | lldb.SBProcess.eBroadcastBitSTDOUT | lldb.SBProcess.eBroadcastBitSTDERR)
    event = lldb.SBEvent()
    while True:
        if listener.WaitForEvent(1, event) and lldb.SBProcess.EventIsProcessEvent(event):
            state = lldb.SBProcess.GetStateFromEvent(event)
        else:
            state = process.GetState()

        if state == lldb.eStateExited:
            os._exit(process.GetExitStatus())
        elif state == lldb.eStateStopped:
            debugger.HandleCommand('bt')
            os._exit({exitcode_app_crash})

        stdout = process.GetSTDOUT(1024)
        while stdout:
            sys.stdout.write(stdout)
            stdout = process.GetSTDOUT(1024)

        stderr = process.GetSTDERR(1024)
        while stderr:
            sys.stdout.write(stderr)
            stderr = process.GetSTDERR(1024)
