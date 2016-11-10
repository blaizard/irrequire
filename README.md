## A super-small require script

Call a function once the object(s), variable(s) or function(s) passed into argument are available.

&#128279; https://www.blaizard.com/projects/irrequire

## Features

* Manage object dependencies
* Small-size
* Singleton-like [(1)](#singleton)

Note: This is not a ressource loader, for that you have the well-known require.js script.

## Getting Started

To execute a function once an object is ready (loaded):
```javascript
// The function will be executed only once Irform and Irexplorer are loaded
irRequire(["Irform", "Irexplorer"], function() {
	alert("ready!");
});
```

<a name="singleton">(1)</a> The script can be included multiple times but only one occurence will be running.<br/>