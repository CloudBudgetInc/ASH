({
	getRichText: function(field, record, dup) {
		var textResult = record;
		var dom = document.createElement("div");
		const domain = window.location.hostname.replace(/\./g, '\\.');
		const regex = new RegExp(`(;a href=&quot;)(http|https)(:\/\/${domain}\\/[^]+?)(&quot; target=&quot;)(_blank)(&quot;)`, 'gm');
		
		if (field === "Rich Text Field 1") {
			if (textResult.contentNodes.FullBody1) {
			if (!dup) {
				dom.innerHTML = textResult.contentNodes.FullBody1.value.replace(
				regex,
				'$1$2$3$4_self$6'
				);
				textResult.contentNodes.FullBody1.value = dom.innerText;
			}
			return textResult.contentNodes.FullBody1.value;
			}
		} else if (field === "Rich Text Field 2") {
			if (textResult.contentNodes.FullBody2) {
			if (!dup) {
				dom.innerHTML = textResult.contentNodes.FullBody2.value.replace(
				regex,
				'$1$2$3$4_self$6'
				);
				textResult.contentNodes.FullBody2.value = dom.innerText;
			}
			return textResult.contentNodes.FullBody2.value;
			}
		} else if (field === "Rich Text Field 3") {
			if (textResult.contentNodes.FullBody3) {
			if (!dup) {
				dom.innerHTML = textResult.contentNodes.FullBody3.value.replace(
				regex,
				'$1$2$3$4_self$6'
				);
				textResult.contentNodes.FullBody3.value = dom.innerText;
			}
			return textResult.contentNodes.FullBody3.value;
			}
		} else if (field === "Rich Text Field 4") {
			if (textResult.contentNodes.FullBody4) {
			if (!dup) {
				dom.innerHTML = textResult.contentNodes.FullBody4.value.replace(
				regex,
				'$1$2$3$4_self$6'
				);
				textResult.contentNodes.FullBody4.value = dom.innerText;
			}
			return textResult.contentNodes.FullBody4.value;
			}
		}
		return "";
	},
	populateAccordionMap: function(cmp) {
		const accordMap = [];

		const accordLabels = [
			cmp.get("v.accordion1Label"), 
			cmp.get("v.accordion2Label"), 
			cmp.get("v.accordion3Label"), 
			cmp.get("v.accordion4Label")
		];
		
		const accordData = [
			cmp.get("v.panel1Desc"), 
			cmp.get("v.panel2Desc"), 
			cmp.get("v.panel3Desc"), 
			cmp.get("v.panel4Desc")
		];

		for (var i = 0; i < accordLabels.length; i++) {
			if (accordLabels[i] !== "" && accordData[i] !== "") {
				accordMap.push({ label: accordLabels[i], content: accordData[i] });
			}
		}

		cmp.set("v.accordionMap", accordMap);
	},
	toggleHeader: function(cmp) {
		if ($A.util.hasClass(cmp, "custom-faq__accordionSectionHeader--open")) {
			$A.util.removeClass(cmp, "custom-faq__accordionSectionHeader--open");
		} else {
			$A.util.addClass(cmp, "custom-faq__accordionSectionHeader--open");
		}
	},
	toggleSection: function(cmp, borderColor) {
		if ($A.util.hasClass(cmp, "custom-faq__accordionSection--open")) {
			$A.util.removeClass(cmp, "custom-faq__accordionSection--open");
			$A.util.removeClass(cmp, `custom-faq__accordionSection--open--${borderColor}`);
		} else {
			$A.util.addClass(cmp, "custom-faq__accordionSection--open");
			$A.util.addClass(cmp, `custom-faq__accordionSection--open--${borderColor}`);
		}
	}
})