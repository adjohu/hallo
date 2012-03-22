#     Hallo - a rich text editing jQuery UI widget
#     (c) 2011 Henri Bergius, IKS Consortium
#     Hallo may be freely distributed under the MIT license
#
#     Colorpicker Plugin (c) 2012 Adam Hutchinson
((jQuery) ->
    # convert RGB to Hex
    RGBtoHex = (r, g, b) ->
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

        # Build the colorpicker using a canvas
        # Based around http://nerderg.com/Canvas+Color+Picker
        _buildColorpicker: ->
            widget = this

            # create a canvas, load colorwheel onto it
            canvas = jQuery("<canvas />")
            ctx = canvas.get(0).getContext('2d')
            img = new Image()
            img.src = @options.imageSrc
            img.onload = ->
              ctx.drawImage(img, 0, 0)

            @colorpicker = canvas

            # bind the click event to emit a colorchanged event
            canvas.on 'click', (evt) ->
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
                #canvas.trigger('colorChange', [hex])
                console.log widget.options.editable
                widget.options.editable.execute 'foreColor', '#' + hex



        # Create the dialog the colorpicker will sit in
        _makeDialog: ->
            @dialog = jQuery("<div />").hide().css('position', 'absolute')
                .append(@colorpicker)
                .appendTo('body') # TODO: find somewhere better to put this

        _toggleDialog: ->
            # Move dialog to be below button
            label = @button.filter 'label'
            position = label.offset()
            height = label.height()
            position.top += height

            @dialog.css position
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
                    widget._toggleDialog()

                @button = button

            # Init colorpicker
            @_buildColorpicker()
            @_makeDialog()

            # Set up button
            buttonize()
            buttonset.buttonset()
            @options.toolbar.append buttonset

        _init: ->

)(jQuery)
