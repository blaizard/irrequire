(function(n) {
	// Create the irRequire only if it does not exists
	if (!n.irRequire) {
		/**
		 * \brief Wait until the object/variable/function is available to execute the callback
		 *
		 * \alias irRequire
		 *
		 * \param functionName Can be a string or an array of string
		 * \param callback The function to be called once the object/variable/function are available
		 * \param [args] Extra arguments to be passed to the callback
		 * \param [timeout] The time in milliseconds, before the function times out.
		 */
		n.irRequire = function (functionName, callback, args, timeout) {
			var id = -1;
			var f = irRequire;
			// If no callback or null, it means it has been called wih an id, then decode
			if (!callback) {
				id = functionName;
				functionName = f.r[id][0];
				callback = f.r[id][1];
				args = f.r[id][2];
				f.r[id][3] -= 100;
				timeout = f.r[id][3];
			}
			// Wait for maximum 5 seconds by default
			if (typeof timeout === "undefined") {
				timeout = 5000;
			}
			// If this is a string, convert it into an array to make the code compatible
			if (typeof functionName === "string") {
				functionName = [functionName];
			}

			// Check if function is ready
			var ready = 1;
			for (var i in functionName) {
				var name = functionName[i];
				try {
					// If the function is not ready
					if (typeof(eval(name)) === "undefined") {
						throw 1;
					}
					n.irRequire.h(name);
				}
				catch (err) {
					ready = 0;
					var urlList = f.map[name] || [];
					if (!(urlList instanceof Array)) {
						urlList = [urlList];
						f.map[name] = [];
					}
					// If the file is not loaded yet
					while (urlList.length) {
						var url = urlList.shift();
						if (f.map.hasOwnProperty(url)) {
							return irRequire(url, function() {
								irRequire(functionName, callback, args, timeout);
							}, args, timeout);
						}
						n.irRequire.h(name, url);
						// Load CSS ressource
						var elt;
						if (url.search(/\.css$/i) >= 0) {
							elt = document.createElement("link");
							elt.href = url;
							elt.rel = "stylesheet";
							elt.type = "text/css";
						}
						// Else load javascript
						else {
							elt = document.createElement("script");
							elt.src = url;
							elt.type = "text/javascript";
						}
						elt.onerror = function() {
							irRequire.e("cannot load " + (elt.src || elt.href));
						};
						document.getElementsByTagName("head")[0].appendChild(elt);
					}
				//	delete f.map[name];
				//	break;
				}
			}

			if (ready) {
				if (id >= 0) {
					clearTimeout(f.r[id][4]);
					f.r[id] = 0;
				}
				callback(args);
			}
			else {
				// Need to create an entry in the pending record
				if (id < 0) {
					f.r.push([functionName, callback, args, timeout]);
					id = f.r.length - 1;
					// Do not throw an error if timeout is initally set to 0
					if (timeout <= 0) {
						return;
					}
				}
				// If the timeout is not over contiue
				if (timeout > 0) {
					f.r[id][4] = setTimeout(function() {
						f(id);
					}, 100);
				}
				// Else keep the callback registered but do not check it anymore
				// It can be done only manually
				else {
					irRequire.e(functionName.join() + " timed-out");
				}
			}
		}

		// Table that will contain the records
		n.irRequire.r = [];

		/**
		 * Map object names with their urls
		 */
		n.irRequire.map = {};

		/**
		 * Error handler, can be overwritten
		 */
		n.irRequire.e = console.error;

		/**
		 * Hook for loading feedback
		 */
		n.irRequire.h = function(){};

		/**
		 * \brief Trigger pending requires. This function is synchronous and 
		 * can be therefore executed once entering or initializing a module.
		 */
		n.irRequire.trigger = function() {
			irRequire.r.forEach(function(item, id) {
				if (item) {
					irRequire(id);
				}
			});
		}
	}
})(window);