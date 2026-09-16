// =========================================================================
// ClinicCare - client-side helpers and validation feedback (rubric ID 6)
// =========================================================================

// ------------------------------------------------------------------------
// CustomValidator callback for the time-slot CheckBoxList.
// A CheckBoxList renders as a group of checkboxes, which RequiredFieldValidator
// cannot target, so "at least one ticked" is checked here on the client and
// again in cvTimeSlot_ServerValidate on the server.
// Declared at global scope because ASP.NET calls it by name.
// ------------------------------------------------------------------------
function ccValidateTimeSlot(sender, args) {
    var group = document.getElementById('MainContent_cblTimeSlots')
             || document.querySelector('[id$="cblTimeSlots"]');

    if (!group) {
        // Fail open: if the control cannot be found, let the server decide.
        args.IsValid = true;
        return;
    }

    var boxes = group.querySelectorAll('input[type="checkbox"]');
    for (var i = 0; i < boxes.length; i++) {
        if (boxes[i].checked) {
            args.IsValid = true;
            return;
        }
    }

    args.IsValid = false;
}

$(function () {

    // Auto-dismiss success alerts after a few seconds so the page stays tidy.
    window.setTimeout(function () {
        $('.alert-success').fadeOut(400);
    }, 6000);

    // Restrict the mobile number fields to digits only.
    $('input[id$="txtPhone"], input[id$="txtNationalID"]').on('input', function () {
        this.value = this.value.replace(/\D/g, '');
    });

    // ---------------------------------------------------------------------
    // Red-border feedback on the inputs that failed validation.
    // ASP.NET's client validators only toggle their own message spans, so the
    // Bootstrap is-invalid class is applied here by inspecting each validator
    // that ASP.NET registered on the page.
    // ---------------------------------------------------------------------
    function ccRefreshFieldStyling() {
        if (typeof Page_Validators === 'undefined' || !Page_Validators) return;

        for (var i = 0; i < Page_Validators.length; i++) {
            var v = Page_Validators[i];
            if (!v.controltovalidate) continue;

            var input = document.getElementById(v.controltovalidate);
            if (!input) continue;

            if (v.isvalid === false) {
                input.classList.add('is-invalid');
            } else {
                // Only clear it when no other validator on the same input failed.
                var stillInvalid = false;
                for (var j = 0; j < Page_Validators.length; j++) {
                    if (Page_Validators[j].controltovalidate === v.controltovalidate &&
                        Page_Validators[j].isvalid === false) {
                        stillInvalid = true;
                        break;
                    }
                }
                if (!stillInvalid) input.classList.remove('is-invalid');
            }
        }
    }

    // Run after ASP.NET finishes its own client-side validation pass.
    if (typeof Page_ClientValidate === 'function') {
        var originalValidate = Page_ClientValidate;
        window.Page_ClientValidate = function (group) {
            var result = originalValidate(group);
            ccRefreshFieldStyling();
            return result;
        };
    }

    // Re-check a field as soon as the user edits it, so the red border clears
    // without waiting for another submit.
    $(document).on('blur change input', 'input, select, textarea', function () {
        var el = this;
        if (typeof Page_Validators === 'undefined' || !Page_Validators) return;

        for (var i = 0; i < Page_Validators.length; i++) {
            if (Page_Validators[i].controltovalidate === el.id &&
                typeof ValidatorValidate === 'function') {
                ValidatorValidate(Page_Validators[i]);
            }
        }
        ccRefreshFieldStyling();
    });

    // Style anything already flagged when the page arrives after a failed postback.
    ccRefreshFieldStyling();

});
