(function(n) {
	// Create the irRequire only if it does not exists
	if (!n.irRequire) {
		/**
		 * \brief Creates a promise and resolve it when the object/variable/function is available.
		 *
		 * \alias irRequire
		 *
		 * \param functionName Can be a string or an array of string
		 * \param [timeout] The time in milliseconds, before the function times out.
		 */
		n.irRequire = function (functionName, timeout) {
			return new Promise(function (resolve, reject) {
				// Wait for maximum 5 seconds by default
				n.irRequire.a(functionName, resolve, reject, timeout || 5000);
			});
		}

		n.irRequire.a = function (functionName, resolve, reject, timeout) {

			// If this is a string, convert it into an array to make the code compatible
			if (typeof functionName === "string") {
				functionName = [functionName];
			}

			// Check if function is ready
			var ready = 1;
			functionName.forEach(function (name) {
				try {
					// If the function is not ready
					if (typeof(eval(name)) === "undefined") {
						throw 1;
					}
					n.irRequire.h(name);
				}
				catch (err) {
					ready = 0;

					// Make sure the map is a list, otherwise force it
					if (!(irRequire.map[name] instanceof Array)) {
						irRequire.map[name] = [irRequire.map[name]];
					}

					// If the file is not loaded yet
					while (irRequire.map[name].length) {
						var url = irRequire.map[name].shift();

						// If the name is part of the global map, load it
						if (irRequire.map[url]) {
							return irRequire(url, timeout).then(function () {
								irRequire.a(functionName, resolve, reject, timeout);
							});
						}
						n.irRequire.h(name, url);

						// Load CSS ressource
						var desc = (url.search(/\.css$/i) >= 0) ? ["link", "href", {rel: "stylesheet", type: "text/css"}]
								: ["script", "src", {type: "text/javascript"}];

						// Create the new element only if it does not exists
						if (!document.querySelector(desc[0] + '[' + desc[1] + '="' + url + '"]')) {

							var elt = document.createElement(desc[0]);
							elt[desc[1]] = url;
							Object.assign(elt, desc[2]);

							elt.onerror = function () {
								reject(new Error("cannot load " + (elt.src || elt.href)));
							};
							document.getElementsByTagName("head")[0].appendChild(elt);
						}
					}
				}
			});

			if (ready) {
				resolve(1);
			}
			else if (timeout > 0) {
				setTimeout(function () {
					irRequire.a(functionName, resolve, reject, timeout - 100);
				}, 100);
			}
			else {
				reject(new Error(functionName.join() + " timed-out"));
			}
		};

		/**
		 * Map object names with their urls
		 */
		n.irRequire.map = {};

		/**
		 * Hook for loading feedback
		 */
		n.irRequire.h = function () {};
	}
})(window);
