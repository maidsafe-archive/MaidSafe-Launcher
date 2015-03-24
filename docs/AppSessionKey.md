# App Session Key

* The key just needs to be an RSA key pair, not a full PKI key like e.g. MAID, since it won't be getting stored permanently by the network.
* The app will generate a new key pair every time it wants to connect to the network.  The same key will be used for the rest of that session.
* The app will be told where to connect to (i.e. the Launcher will pass the name of the PublicMaid to it via IPC, and it will connect at that location).
* The app will reply with its public session key via IPC.
* The Launcher will pass this to the MaidManager group which will hold it in memory (not put to permanent storage)  It should be passed around as per accounts when churn happens at the MM group.  The Launcher could also pass a random string as a challenge for the MM group to pass to the app once it connects.
* The app will connect to the MaidManager group.  It can either then be given the challenge if the Launcher passed one to the group, or it can generate its own random string for using to prove ownership of the private key.
* The app signs the challenge and passes it to the group.
* For the duration of the connection, that app is allowed to perform the same operation as if it were holding the MAID.  All requests to the network must be signed with the session key and these must be checked by the MM group.
* Once the app disconnects, the session key is dropped by the MM group **or** the Launcher has to request the removal of the key (needs to be decided).
