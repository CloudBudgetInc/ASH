({
  fetchContact: function(component) {
		const action = component.get("c.getContact");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	checkMember: function(component) {
		const action = component.get("c.checkMemberStatus");

		return new Promise(function(resolve, reject) {
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	updateMemberDirectory: function(component, memberDir) {
		const action = component.get("c.updateMemberDirectory");

		return new Promise(function(resolve, reject) {
			action.setParam("memberDir", memberDir);
			action.setCallback(this, function(response) {
				const state = response.getState();
				if (state === "SUCCESS") {
					resolve(response.getReturnValue());
				} else {
					reject(response.getError()[0]);
				}
			});
			$A.enqueueAction(action);
		});
	},
	resetEffortBar: function() {
		window.setTimeout(function() {
			const values = document.getElementsByClassName('value');
			Array.from(values).forEach(function(val) {
				const text = val.textContent;
				val.parentNode.style.width = text;
			});
		}, 200);
	}
})