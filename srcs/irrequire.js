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
			try {
				for (var i in functionName) {
					// If the function is not ready yet
					if (typeof(eval(functionName[i])) === "undefined") {
						ready = 0;
						break;
					}
				}
			}
			catch(err) {
				ready = 0;
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
				}
				// If the timeout is not over contiue
				if (timeout > 0) {
					f.r[id][4] = setTimeout(function() {
						f(id);
					}, 100);
				}
			}
			// Else keep the callback registered but do not check it anymore
			// It can be done only manually
		//	else {
		//		 console.log("irRequire timed out");
		//	}
		}

		// Table that will contain the records
		n.irRequire.r = [];

		/**
		 * \brief Trigger pending requires. This function is synchronous and 
		 * can be therefore executed once entering or initializing a module.
		 */
		n.irRequire.trigger = function () {
			irRequire.r.forEach(function(item, id) {
				if (item) {
					irRequire(id);
				}
			});
		}
	}
})(window);