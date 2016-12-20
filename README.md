## A super-small require script

Call a function once the object(s), variable(s) or function(s) passed into argument are available.
References can also be mapped to a javascript file URL which will be loaded automatically if the reference is not available.

&#128279; https://www.blaizard.com/projects/irrequire

## Features

* Manage object dependencies
* Small-size
* Singleton-like [(1)](#singleton)

## Getting Started

To execute a function once an object is ready (loaded):
```javascript
// The function will be executed only once Irform and Irexplorer are loaded
irRequire(["Irform", "Irexplorer"], function() {
	alert("ready!");
});
```

To set-up the reference <-> url map
```javascript
// Will load the jquery file and call the callback once "jQuery" becomes a recognized object
irRequire.map = {
	"jQuery": "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
};
irRequire(["jQuery"], function() {
	alert("ready!");
});
```

<a name="singleton">(1)</a> The script can be included multiple times but only one occurence will be running.<br/>