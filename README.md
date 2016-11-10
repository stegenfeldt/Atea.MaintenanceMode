# Atea.MaintenanceMode
OpsMgr 2012 (SCOM 2012) Manegement Pack, Windows Desktop Client and Installer Projects to set maintenance mode from within a monitored system.

## About the naming

I am a big proponent of separating namespaces and since I have developed this package as an employee of Atea Sverige AB I have chosen to use Atea.* as the namespace for most of my management packs.
This project is uploaded to Github under the MIT-license, so feel free to fork and modify as you like.

## Post-build script and other tools

I have, in my projects, post-build scripts that will sign the binaries with my personal code signing key.
You would have to alter, or disable, these to avoid errors in the build logs. I will *not* provide my private key to the code signing certificate as that would defeat the purpose of signing the binaries. 
The solution also uses the Auto Deploy extension to automatically copy build artefacts to the "/Downloads" folder. Unfortunately, this extension seems to be saving it's configuration somewhere outside of the solution so installation av configuration will have to be done manually on each computer.

## Acknowledgements and Credits

Inspired by, and initially based on [Natasha Heil's](https://systemcentertipps.wordpress.com/) [management pack](http://www.systemcentercentral.com/pack-catalog/sample-agent-maintenance-mode-2012-mp/).
Go pay her a visit, her blog is full of usefull System Center stuff, or follow her on twitter [@NatasciaHeil](https://twitter.com/NatasciaHeil)! Permission to share under MIT has been given by Natascia.
