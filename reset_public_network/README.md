###How to use the scripts:

1. Get your token using the getToken.sh script:

./getToken.sh user apikey

2. Update your os_env with the token, serverid, and networkid then source the os_env file.
source os_env

3. Retrieve your interface ID for the server.
./listInterfaces

4. Plug the interface id into the os_env, then source it again to prepare for the delete script.

5. Run the delete script to remove the public interface.

6. Run the add script to add the public network back to the server and obtain a new public IP address.
