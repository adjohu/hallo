#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
#
#     Colorpicker Plugin (c) 2012 Adam Hutchinson
((jQuery) ->
    # convert RGB to Hex
    RGBtoHex = (r, g, b) ->
        console.log(r,g,b)
        hex = (x) ->
            ("0" + parseInt(x).toString(16)).slice(-2)

        hex(r) + hex(g) + hex(b)

    jQuery.widget "IKS.hallocolorpicker",
        options:
            label: 'color'
            command: 'color'
            editable: null
            toolbar: null
            uuid: ""
            imageSrc: '/editor/js/libs/hallo/img/colorwheel.png'
            canvas:
                width: 100
                height: 100

        # Build the colorpicker using a canvas
        # Based around http://nerderg.com/Canvas+Color+Picker
        _buildColorpicker: ->
            widget = this

            # create a canvas, load colorwheel onto it
            canvas = jQuery("<canvas width='#{@options.canvas.width}' height='#{@options.canvas.height}' />")
            ctx = canvas.get(0).getContext('2d')
            img = new Image()
            img.src = @options.imageSrc
            img.onload = ->
              ctx.drawImage(img, 0, 0)

            @colorpicker = canvas

            # bind the click event to emit a colorchanged event
            canvas.on 'mousedown', (evt) ->
                # get position of click relative to canvas
                {left, top} = canvas.offset()
                {pageX, pageY} = evt
                x = pageX - left
                y = pageY - top

                # Get color at position of click
                i = ctx.getImageData(x, y, 1, 1).data

                # Convert to hex
                hex = RGBtoHex i[0], i[1], i[2]

                # Trigger color change event
                console.log(widget.button)
                widget.button.trigger 'colorChange', ['#' + hex]
                #widget.options.editable.execute 'foreColor', '#' + hex


        _buildInput: ->
            widget = this
            input = jQuery('<input type="text" />')
                .on('keyup', ->
                    widget.button.trigger 'colorChange', input.val()
                )
            @colorPickerInput = input

        _observeColorChange: ->
            widget = this
            @button.on 'colorChange', (evt, hex) ->
                console.log arguments
                widget.options.editable.restoreSelection(widget.lastSelection)
                widget.options.editable.execute 'foreColor', hex
                widget.colorPickerInput.val hex

        # Create the dialog the colorpicker will sit in
        _makeDialog: ->
            widget = this
            @dialog = jQuery("<div class='hallodropdown #{widget.name}' />").hide().css('position', 'absolute')
                .append(@colorpicker)
                .append(@colorPickerInput)
                .appendTo('body') # TODO: find somewhere better to put this

            # Make dialog hide on hallo deactivated
            @options.editable.element.bind "hallounselected halloselected hallodeactivated", ->
                widget._closeDialog()


        _closeDialog: ->
            @_toggleDialog() unless @dialog.is(':hidden')

        _toggleDialog: ->
            # Move dialog to be below button
            label = @button.filter 'label'
            position = label.offset()
            height = label.height()
            position.top += height
            @dialog.css position

            # Fill input with current colour
            color = document.queryCommandValue('foreColor')
            rgb = color.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/)
            console.log rgb
            color = RGBtoHex.apply @, rgb.splice(1)
             
            @colorPickerInput.val '#' + color

            @dialog.toggle()


        _create: ->
            widget = this

            buttonset = jQuery "<span class=\"#{widget.widgetName}\"></span>"
            buttonize = =>
                # id of the button
                id = "#{@options.uuid}"

                # append a new button to the buttonset
                button = jQuery("<input id=\"#{id}\" type=\"checkbox\" /><label for=\"#{id}\">#{@options.label}</label>").button()
                buttonset.append button

                button.bind "change", (event) ->
                    # Save the last selection as we may lose focus
                    widget.lastSelection = widget.options.editable.getSelection()
                    widget._toggleDialog()

                @button = button

            # Set up button
            buttonize()

            # Init colorpicker
            @_buildColorpicker()
            @_buildInput()
            @_makeDialog()

            # Set up colorchange observer
            @_observeColorChange()

            buttonset.buttonset()
            @options.toolbar.append buttonset

        _init: ->

)(jQuery)
