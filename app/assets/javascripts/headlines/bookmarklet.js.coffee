#=require headlines/headlines
#=require zepto
#=require underscore
#=require backbone
#=require_directory ./book_templates

$ = Zepto

class headlines.Bookmarklet
    DefaultOptions:
        header: "http://eworld.dev/assets/headlines/headlines400.jpg"
                        
    constructor: (options) ->
        @options = _(_({}).extend(@DefaultOptions)).extend options||{}
        
        console.log "Success!"

        # -- init our headline -- #
        
        @h = new Bookmarklet.Headline()
        
        # -- look for our og: tags -- #

        # url
        if (u = $ 'meta[property="og:url"]') && u.length
            @h.set url:u.attr "content"
        else
            @h.set url:window.location

        # title
        if (t = $ 'meta[property="og:title"]') && t.length
            @h.set title:t.attr "content"
        else if (t = $ 'title') && t.length
            @h.set title:t.text()
        else
            @h.set title:""
        
        # content
        if s = window.getSelection() && s? && s.toString() != ""
            @h.set descript:s.toString()
        else if (c = $ 'meta[property="og:description"]') && c.length
            @h.set descript:c.attr "content"
        else if (c = $ 'meta[name="description"]') && c.length
            @h.set descript:c.attr "content"
        
        # thumbnail
        if (th = $ 'meta[property="og:image"]') && th.length
            @h.set image:th.attr "content"
        
        # -- create modal -- #
        
        divPREFIX = "ewrBook"
            
        @hV = new Bookmarklet.HeadlineView model:@h, header:@options.header
        
        # -- create floating div -- #
        $("body").append JST["headlines/book_templates/shell"] divPREFIX:divPREFIX
        @container = $("##{divPREFIX}CONTAINER")
        @container.css "top", window.pageYOffset
        
        @frame = $("##{divPREFIX}FRAME")[0].contentWindow.document
        @frame.open()
        @frame.close()
        $("body", $ @frame ).append @hV.el
        
        # FIXME: now set our height to the rendered elements
        #@container.height $("#bdBookFRAME").height $(hV.el).height()
    
        # attach scroll listener
        $(window).bind "scroll", (e) =>
            console.log "scroll event"
            @container.css "top", window.pageYOffset

        @hV.bind "save", =>
            # hide the headline form
            $(@hV.el).hide()

            # trigger save on our model
            @h.save {}, 
                success:(m,resp) =>                     
                    # show a success button
                    $(@hV.el).before "<button id='success'>Success</button>"
                error:(m,resp) =>
                    $(@hV.el).before "<button id='success'>Error: #{resp.error}</button>",
                json:$("##{divPREFIX}FRAME")[0].contentWindow.JSON
    
    #----------
                                        
    @Sync: (method, model, options) ->
        methodMap = {
            'create': 'POST',
            'update': 'PUT',
            'delete': 'DELETE',
            'read'  : 'GET'
        }
        
        getUrl = (object) ->
            if !(object && object.url)
                return null
                
            return if _.isFunction(object.url) then object.url() else object.url

        # Throw an error when a URL is needed, and none is supplied.
        urlError = ->
            throw new Error('A "url" property or function must be specified')
        
        type = methodMap[method];
        
        ewrJSON = options.json

        # Default JSON-request options.
        params = _.extend
            type: type,
            dataType: 'json',
            json: null
        , options;

        # Ensure that we have a URL.
        if !params.url
            params.url = getUrl(model) || urlError()

        # Ensure that we have the appropriate request data.
        if !params.data && model && (method == 'create' || method == 'update')
            params.contentType = 'application/json';
            params.data = ewrJSON.stringify(model.toJSON())

        # Don't process data on a non-GET request.
        if params.type != 'GET' && !Backbone.emulateJSON
            params.processData = false;
        
        # add credentials
        params.beforeSend = (xhr,settings) ->
            xhr.withCredentials = "true"
            true

        # Make the request.
        return Zepto.ajax params
                    
    #----------
        
    @Headline:
        Backbone.Model.extend
            sync: @Sync
            urlRoot: "http://" + headlines.SERVER + headlines.PATH + "/"
            
    #----------
    
    @HeadlineView:
        Backbone.View.extend            
            events:
                "click button#desc_select": "_descFromSelection"
                "click button#save": "_save"
            
            #----------
            
            initialize: ->                
                @render()
                                            
                @drop = @$ "#drop"
                @addImage @model.get "image"

                # set up drop listeners
                @drop.bind "dragenter", (e) => @_dropDragEnter e
                @drop.bind "dragover", (e) => @_dropDragOver e
                @drop.bind "drop", (e) => @_dropDrop e
            
            #----------
            
            _dropDragEnter: (e) ->
                e = e.originalEvent if e.originalEvent?
                e.stopPropagation()
                e.preventDefault()
                false
                
            _dropDragOver: (e) ->
                e = e.originalEvent if e.originalEvent?
                e.stopPropagation()
                e.preventDefault()
                false
                
            _dropDrop: (e) ->
                console.log "drop event is ", e                
                e = e.originalEvent if e.originalEvent?
                e.stopPropagation()
                e.preventDefault()
                
                uri = e.dataTransfer.getData 'text/uri-list'
                
                console.log "drop uri is ", uri
                @addImage(uri)                
                
            #----------
            
            addImage: (uri) ->
                if !uri?
                    return false
                    
                # load the image into our drop element
                @drop.html "<img src='#{uri}' id='drop_img'/>"
                @drop_img = @$ "#drop_img"
                @model.set image:uri
                @_renderImg()

            _renderImg: ->
                # scale image...
                w = @drop_img.width()
                h = @drop_img.height()
                
                # only continue if we get a width and height
                if !w || !h
                    console.log "dropImg not ready, delaying"
                    _.delay ( => @_renderImg() ), 100
                    return false
                                                    
                hscale = vscale = 1
                if w > @drop.width()
                    hscale = @drop.width() / w
                    
                if h > @drop.height()
                    vscale = @drop.height() / h
                    
                console.log "hscale, vscale: ", hscale, vscale
                
                scale = if hscale > vscale then hscale else vscale
                
                @drop_img.css "width", w * scale
                @drop_img.css "height", h * scale
                @drop_img.css "position", "relative"
                
                console.log "w/h set to ", w*scale, h*scale
                
                # and center...
                if w > h
                    pad = @drop_img.width() - @drop.width()
                    @drop_img.css "left", "#{-pad / 2}px"
                else if h > w
                    pad = @drop_img.height() - @drop.height()
                    @drop_img.css "top", "#{-pad / 2}px"
                    
            #----------
            
            _save: (e) ->
                # save our values back to the model
                @model.set
                    intro:      @$("#intro").val()
                    title:      @$("#title").val()
                    url:        @$("#url").val()
                    descript:   @$("#descript").val()
                    image:      @drop_img.attr("src")
                
                @trigger "save"
                
            #----------
            
            _descFromSelection: (e) ->
                console.log "in descFromSel", window.getSelection()
                if s = window.getSelection()
                    #@model.set descript:s.toString()
                    @$("#descript")[0].value = s.toString()
                    
                    console.log "selection is ", s.toString()
                else
                    console.log "not a selection?"
                    
                true
            
            #----------
            
            render: ->
                $(@el).html JST["headlines/book_templates/headline"]
                    h: @model.toJSON()
                    header: @options.header
   
                @