# Building and Deploying with Travis

### Setup Travis web
 1) To get started with Travis, follow the first 3 steps in the following tutorial:
    - https://docs.travis-ci.com/user/tutorial/#to-get-started-with-travis-ci
    - For step 3, make sure you include activating your fork of this repository

### Create Firebase account
 1) Navigate to https://console.firebase.google.com
 2) Sign in/make an account
 3) Create a new project:
    - For project name, use `{your username}-tba-dev`
    - Leave the other settings to the defaults, unless you know what you're doing

    ![](https://i.imgur.com/tk4kWtn.png)

 4) On the left, navigate to Develop -> Storage
    - After clicking through a few confirmations, you should be on a screen like this:

    ![](https://i.imgur.com/tpFcxrU.png)

5) Copy your storage URL for later use:
   - Copy the storage URL, which is `gs://dracco1993-tba-dev-17792.appspot.com` in this example, to some place you'll remember; we'll need this URL in a later step.

### Create/Download Firebase keys
 1) On the top left of Firebase, click the gear icon, then go to Project Settings
 2) From here, go to the Service Accounts tab
 3) Click "Generate new private key", then confirm by clicking "Generate key"
    - Generating a key in this manner will download a new `.json` file, containing all the information required to access this Firebase project via an API
    - As the warning in Firebase says, "Keep it confidential and **never store it in a public repository**"

### Encrypt Firebase keys with Travis CLI
 1) Setup the Travis CLI:
    - https://github.com/travis-ci/travis.rb#installation
 2) Login to the Travis CLI
    - First, make sure that you're inside this repository's directory in terminal before running commands.  Being inside of the repository's directory allows Travis to automatically figure out the information necessary to link the following commands to your project in Travis, by looking at the `.git` metadata folder locally.

    - Next, log in to Travis via the command line with the following command:
      ```bash
      $ travis login
      ```
      - As part of this command, Travis will ask you for you GitHub credentials.  Travis does not store these.  Rather, it uses them to generate an API token, verifies that you are who you say you are, then deletes the token.
      - If you're weary of using your username and password, or want to learn more about what this command does, check out the following documentation for more details and other ways you can authenticate against GitHub:
        - https://github.com/travis-ci/travis.rb#login

 3) Encrypt Firebase keys
    - At this point, we need to encrypt the `.json` file that we downloaded from Firebase previously.  Travis has a very nice way to do this, that allows us to upload the encrypted file inside our repository, but for only Travis to be able to decrypt it when it's actually running a build.
      ```bash
      $ travis encrypt-file PATH_TO_DOWNLOADED_FILE.json gcp-service-key.json.enc
      ```
    - This command encrypts the `.json` file from Firebase, and sets two environment variables in your Travis project
    - Note: the input path will be to wherever you put the Firebase key file, but to keep things easier, the output path will be the encoded `.json.enc` file already in the repository
    - The full documentation for this command is available here:
      - https://github.com/travis-ci/travis.rb#encrypt-file
    - Usages and examples can be found here:
      - https://docs.travis-ci.com/user/encrypting-files/

### Update Travis environment variables
 1) We need to update the environment variables that Travis uses to decrypt the `.json.enc` we just created
 2) First, navigate to the setting page for your repository by clicking More Options -> Settings in the top right hand corner:

    ![](https://i.imgur.com/MGzMaT7.png)
 3) In the Environment Variables section, you should see two variables already defined for you, from when you encrypted the Firebase file with Travis CLI:

     ![](https://i.imgur.com/A04Bua9.png)
 4) The first two variables we'll add are going to reference the two variables mentioned previously.  The names will be static, as mentioned below, but the values will be the names of the generated keys, prefaced with a `$`:
     - First, one to reference the key:
       - Name: `encrypted_key_name`
       - Value: `${name_of_encrypted_key_var}`
       - Example: `$encrypted_cb3726d3b29b_key`
     - Second, one to reference the iv:
       - Name: `encrypted_iv_name`
       - Value: `${name_of_encrypted_iv_var}`
       - Example: `$encrypted_cb3726d3b29b_iv`
     - The last variable we'll add is the reference to the Firebase storage we made earlier:
       - Name: `firebase_bucket`
       - Value: `gs://{your username}-tba-dev.appspot.com`
       - Example: `gs://dracco1993-tba-dev-17792.appspot.com`
 5) Your final environment variable configuration should look something like this:

    ![](https://i.imgur.com/ZquQttX.png)

### Commit changes
 1) After following the previous steps, you should have one file that you've updated and need to commit to the repository:
    - `gcp-service-key.json.enc`

    NOTE: **make sure you DO NOT commit the unencrypted `.json` file**
 2) `git push` your changes

### Confirmation everything worked
 1) Check Travis.
    - After pushing, on the left-hand side you should see a build running for your repository
    - Click the build to view more information:
      - Scroll down to the bottom of the logs
      - On the second to last line, you should see something like this:
        ```bash
        $ gsutil cp react-native.zip $firebase_bucket/react-native/react-native.zip
        Copying file://react-native.zip [Content-Type=application/zip]...
        / [1 files][173.6 KiB/173.6 KiB]
        Operation completed over 1 objects/173.6 KiB.
        ```
      - If you see this, everything is working and you can continue on to the next step
 2) Check Firebase.
    - Navigate to/refresh your Firebase storage page
    - Inside the `react-native/` folder, you should see your final build: `react-native.zip`
