(($) ->

  unless Modernizr.touch and Modernizr.inputtypes.date

    # Initializes date fields
    $(document).on "focusin click keyup change", "input[type='date']", (event) ->
      element = $(this)
      if element.attr("autocomplete") isnt "off"
        locale = element.attr("lang") or I18n.locale.slice(0, 2) # until we get corresponding locale codes
        options = {}
        $.extend options, $.datepicker.regional[locale],
          dateFormat: "yy-mm-dd"
        element.datepicker options
        element.attr "autocomplete", "off"
      return

    $(document).on "focusin click keyup change", "input[type='daterange']", (event) ->
      element = $(this)
      if element.attr("autocomplete") isnt "off"
        element.attr("lang")
        locale = element.attr("lang") or I18n.locale.slice(0, 2) # until we get corresponding locale codes
        options = {}
        $.extend options,
          format: "YYYY-MM-DD"
          language: locale
          showShortcuts: false
          showTopbar: false
          separator: ' – '
        element.dateRangePicker options
        element.attr "autocomplete", "off"
      return

    # Initializes datetime fields
    $(document).on "focusin click keyup change", "input[type='datetime']", (event) ->
      element = $(this)
      if element.attr("autocomplete") isnt "off"
        locale = element.attr("lang") or I18n.locale.slice(0, 2) # until we get corresponding locale codes
        element.datetimepicker
          format: "YYYY-MM-DD HH:mm"
          locale: locale
          sideBySide: true
          icons:
            time: 'icon icon-time'
            date: 'icon icon-calendar'
            up: 'icon icon-chevron-up'
            down: 'icon icon-chevron-down'
            previous: 'icon icon-chevron-left'
            next: 'icon icon-chevron-right'
            today: 'icon icon-screenshot'
            clear: 'icon icon-trash'
            close: 'icon icon-remove'
          showClear: true
          showClose: true
          showTodayButton: true
          widgetPositioning:
            horizontal: 'auto'
            vertical: 'bottom'
        element.attr "autocomplete", "off"
      return

    $(document).on "focusout", "input[type='date']", (event) ->
      element = $(event.target)
      checkDateAfter = element.attr('data-check-date-after')

      if !checkDateAfter
        return

      inputValue = $(element).val()
      inputDate = new Date(inputValue)
      limitDate = new Date(checkDateAfter)
      submitButton = $(this).closest('form').find('input[type="submit"]')

      if inputValue == '' || inputDate < limitDate
        $(submitButton).attr('disabled', 'disabled')
        $(element).after('<span class="help-inline">Nom ne peut pas être vide</span>')
      else if $(submitButton).attr('disabled')
        $(submitButton).removeAttr('disabled')
        $(element).parent().find('.help-inline').remove()


  return

) jQuery
