# PassPhrase
Generate easy to remember passphrases.

[![GitHub license](https://img.shields.io/github/license/ellygaytor/PassPhrase)](https://github.com/ellygaytor/PassPhrase/blob/master/LICENSE)

## Why use passphrases?

Passwords are an essential part of everyone’s life. But they’re hard to remember, hard to make secure, and annoying to come up with. By creating passphrases instead of passwords, we can make it easier to remember them. This app creates grammatically correct sentences that meet all the requirements for a secure password - they’re long, have mixed capitalization, numbers, and special characters.

## How secure is this?

*The short answer is ”probably secure”.*

The long answer is ”it depends”. This app is written in Swift and SwiftUI. It uses the system’s random number generator, which the Swift documentation says is secure. On iOS devices it is (according to Apple), so the app should be fine in terms of secure random. The bigger concern when using a tool like this is the limited dictionary. An attacker with a copy of your hashed password and with knowledge of how you generated it (i.e. this app and the options you have chosen) could check all the possible hashes in a number of hours. However, the likely hood of \na) the attacker knowing those things... \nb) the attacker being willing to extract the dictionaries used just to obtain one password... \nc) the likelihood that they would have access to your hashed password (which would require the service you are using the password with to get hacked)... \nis miniscule. That is to say, this app is less than ideal for individuals who feel they may be directly targeted, but for everyone else, it’s fine. The ideal use case for an application like this would be to use it to create a master password for a password manager, which would not store your hashed password as the decryption of the vault is done locally. That means that the attacker would have to compromise the encryption between your device and the password manager’s servers, or otherwise obtain the vault, obtain knowledge of the exact options used to generate the password, and be willing to try billions of potential matches, which would take longer without knowledge of the hashed form of the password (as the attacker would need to attempt to decrypt the blob for every password). This significantly decreases the attack surface.

## How big are the dictionaries?

The number of items in each dictionary fluctuates between versions as bad combinations are removed and new words are added.

