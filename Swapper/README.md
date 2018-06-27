# ParcelX Token-Swapper Deamon

## Features:
1. Monitor & Manage the whole progress of ParcelX public tokensales.
2. Ensure GPX converted from ethereum token to our mainchain.

## Environment:
+  To build & run this golang project, you need create a soft link from this folder into $GOPATH\src\parcelx.io\Swapper.
+  In windows, using command: "mklink /D"
+  Prepare "go get github.com/bitly/go-simplejson"
+  Prepare "go get github.com/larspensjo/config"

## Project Structure:
*  File 'main.go' is the main entry. 
*  Directory 'sale' serves feature 1). 
*  Directory 'swap' serves feature 2).
*  Directory 'tool' contains stand-alone runable programs.

