## A super-small require script (1KB or 0.57KB gzipped)

Creates a promise that will be resolved only once the object(s), variable(s) or function(s) passed into argument are available.
References can also be mapped to a javascript file URL which will be loaded automatically if the reference is not available.

&#128279; [https://blaizard.github.io/irrequire](https://blaizard.github.io/irrequire)

## Download

* [irrequire.min.js](https://blaizard.github.io/irrequire/dist/irrequire.min.js)

## Features

* Manage object dependencies
* Small-size
* Singleton-like [(1)](#singleton)
* Prevent from loading twice the same file
* Promise resolve into the object requested

## Getting Started

To execute a function once an object is ready (loaded):
```javascript
// The function will be executed only once Irform and Irexplorer are loaded
irRequire(["Irform", "Irexplorer"]).then(() => {
	alert("ready!");
});
```

To set-up the reference <-> url map
```javascript
// Will load the jquery file and call the callback once "jQuery" becomes a recognized object
irRequire.map = {
	"jQuery": "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js",
	"$().accordion": ["jQuery", "https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/themes/smoothness/jquery-ui.css", "https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"]
};
irRequire(["$().accordion"]).then(() => {
	alert("ready!");
});
```

Using the keyword await inside an asynchronous function, you can use it as follow:
```javascript
// Setup the map to tell where is located the jQuery module
irRequire.map = {
	"jQuery": "https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"
};

// Fetch and load the jQuery module
var jq = await irRequire("jQuery");

// For example to get info on your IP address
jq.getJSON("http://ipinfo.io", function(data) {
	alert(JSON.stringify(data));
});
```


<a name="singleton">(1)</a> The script can be included multiple times but only one occurence will be running.<br/>
