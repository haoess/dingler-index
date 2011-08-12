 // --- Revised setupFilterHighlightControls.js ----

function centerTimeline(date) {
    tl.getBand(0).setCenterVisibleDate(Timeline.DateTime.parseGregorianDateTime(date));
}


var nameOfFilters = new Array('Dingler Events','Wissenschaft, Technologie','Weltausstellungen','Firmengründungen','Politik, Religion','Architektur, Städtebau','Literatur, Philosophie, Kunst, Musik','Patentrecht','Anderes');
var valOfFilters =  new Array('grey','blue','lightblue','black','pink','green','red','orange','yellow');
var numOfFilters = nameOfFilters.length;

function setupFilterHighlightControls(div, timeline, bandIndices, theme) {
   
    // Init Handler
    var handler = function(elmt, evt, target) {
        onKeyPress(timeline, bandIndices, div, theme);
    };
   
    // Create Filter Div
    var filterDiv = document.createElement("div");
    filterDiv.className = "rightbox";

    // Filter Div Head
    var filterDivHead = document.createElement("div");
    filterDivHead.className = "rightboxhead";
    filterDivHead.innerHTML = "Themen:";
    filterDiv.appendChild(filterDivHead);
    
    // Filter Div Content
    var filterDivContent = document.createElement("div");
    filterDivContent.className = "rightboxcontent";

    // Create Table
    var filterDivTable = document.createElement("table");
    
    /* Create the text inputs for the filters and add eventListeners */
    for(var i=0; i < numOfFilters; i++) {
        //New Row for each filter cat
	tr = filterDivTable.insertRow(i);
    	tr.style.verticalAlign = "top";

	td = tr.insertCell(0); 
        var input = document.createElement("input");
        input.type = "checkbox";
	input.value = valOfFilters[i];
	//input.checked = "checked";
        SimileAjax.DOM.registerEvent(input, "keypress", handler);
        td.appendChild(input);
	$(td).append("<img src='../../static/images/circle-"+valOfFilters[i]+".png'>"+nameOfFilters[i]); // jquery @ToDo rewrite in pure JS
        input.id = "filter"+i;
    }
    filterDivContent.appendChild(filterDivTable);
    filterDiv.appendChild(filterDivContent);
    div.appendChild(filterDiv);

    // Create Highlight Div
    var highlightDiv = document.createElement("div");
    highlightDiv.className = "rightbox";

    // Highlight Div Head
    var highlightDivHead = document.createElement("div");
    highlightDivHead.className = "rightboxhead";
    highlightDivHead.innerHTML = "Suche:";
    highlightDiv.appendChild(highlightDivHead);

    // highlight Div Content
    var highlightDivContent = document.createElement("div");
    highlightDivContent.className = "rightboxcontent";

    // Create Table
    var highlightDivTable = document.createElement("table");
   
    // Highlight Rows   
       /* Create the text inputs for the highlights and add event listeners */
       for (var i = 0; i < theme.event.highlightColors.length; i++) {
           tr = highlightDivTable.insertRow(i);
           td = tr.insertCell(0);
       
           input = document.createElement("input");
           input.type = "text";
           SimileAjax.DOM.registerEvent(input, "keypress", handler);
           td.appendChild(input);
       
           input.id = "highlight"+i;
       
           var divColor = document.createElement("div");
           divColor.style.height = "0.5em";
 	   divColor.className = "input_border";
           divColor.style.background = theme.event.highlightColors[i];
           td.appendChild(divColor);
    }
    highlightDivContent.appendChild(highlightDivTable);
    highlightDiv.appendChild(highlightDivContent);
    div.appendChild(highlightDiv);
   
    // Create Button Div
    var buttonDiv = document.createElement("div");
   
    // create the filter button
    var filterButton = document.createElement("button");
    filterButton.innerHTML = "Filter";
    filterButton.id = "filter"
    filterButton.className = "buttons"
    SimileAjax.DOM.registerEvent(filterButton, "click", handler);
    buttonDiv.appendChild(filterButton);
   
    // create the clear all button
    var highlightButton = document.createElement("button");
    highlightButton.innerHTML = "Clear All";
    highlightButton.id = "clearAll"
    highlightButton.className = "buttons"
    SimileAjax.DOM.registerEvent(highlightButton, "click", function() {
        clearCatAll(timeline, bandIndices, div, theme); //changed to clearCatAll
    });
    buttonDiv.appendChild(highlightButton);
   
    div.appendChild(buttonDiv);
}

var timerID = null;
var filterMatcherGlobal = null;
var highlightMatcherGlobal = null;

function onKeyPress(timeline, bandIndices, div, theme) {
    if (timerID != null) {
        window.clearTimeout(timerID);
    }
    timerID = window.setTimeout(function() {
        performCatFiltering(timeline, bandIndices, div, theme); // changed to performCatFiltering
    }, 300);
}
function cleanString(s) {
    return s.replace(/^\s+/, '').replace(/\s+$/, '');
}

function performFiltering(timeline, bandIndices, table) {
    timerID = null;
    var tr = table.rows[1];
   
    // Add all filter inputs to a new array
    var filterInputs = new Array();
    for(var i=0; i<numOfFilters; i++) {
      filterInputs.push(cleanString(tr.cells[i].firstChild.value));
    }
   
    var filterMatcher = null;
    var filterRegExes = new Array();
    for(var i=0; i<filterInputs.length; i++) {
        /* if the filterInputs are not empty create a new regex for each one and add them
        to an array */
        if (filterInputs[i].length > 0){
                        filterRegExes.push(new RegExp(filterInputs[i], "i"));
        }
                filterMatcher = function(evt) {
                        /* iterate through the regex's and check them against the evtText
                        if match return true, if not found return false */
                        if(filterRegExes.length!=0){
                           
                            for(var j=0; j<filterRegExes.length; j++) {
                                    if(filterRegExes[j].test(evt.getText()) == true){
                                        return true;
                                    }
                            }
                        }
                        else if(filterRegExes.length==0){
                            return true;
                        }    
                   return false;
                };
    }
   
    var regexes = [];
    var hasHighlights = false;
    tr=table.rows[3];
    for (var x = 0; x < tr.cells.length; x++) {
        var input = tr.cells[x].firstChild;
        var text2 = cleanString(input.value);
        if (text2.length > 0) {
            hasHighlights = true;
            regexes.push(new RegExp(text2, "i"));
        } else {
            regexes.push(null);
        }
    }
    var highlightMatcher = hasHighlights ? function(evt) {
        var text = evt.getText();
        var description = evt.getDescription();
        for (var x = 0; x < regexes.length; x++) {
            var regex = regexes[x];
            //if (regex != null && (regex.test(text) || regex.test (description))) {
            if (regex != null && regex.test(text)) {
                return x;
            }
        }
        return -1;
    } : null;
   
    // Set the matchers and repaint the timeline
    filterMatcherGlobal = filterMatcher;
    highlightMatcherGlobal = highlightMatcher;   
    for (var i = 0; i < bandIndices.length; i++) {
        var bandIndex = bandIndices[i];
        timeline.getBand(bandIndex).getEventPainter().setFilterMatcher(filterMatcher);
        timeline.getBand(bandIndex).getEventPainter ().setHighlightMatcher(highlightMatcher);
    }
    timeline.paint();
}

// perform Filtering hack for Category Filtering, maybe better integrated in performFiltering funtion with extra attribut
function performCatFiltering(timeline, bandIndices, div, theme) {
    timerID = null;
   
    // Add all filter inputs to a new array
    var filterInputs = new Array();
    for(var i=0; i < numOfFilters; i++) {
	var tr = div.firstChild.childNodes[1].firstChild.rows[i];// wander through DOM to table
	if($(tr.cells[0].firstChild).attr('checked')){   //check for checkbox selection
		filterInputs.push(cleanString(tr.cells[0].firstChild.value));
	}
    }
   
    var filterMatcher = null;
    var filterRegExes = new Array();
    for(var i=0; i<filterInputs.length; i++) {
        /* if the filterInputs are not empty create a new regex for each one and add them
        to an array */
        if (filterInputs[i].length > 0){
                        filterRegExes.push(new RegExp(filterInputs[i], "i"));
        }
                filterMatcher = function(evt) {
                        /* iterate through the regex's and check them against the evtText
                        if match return true, if not found return false */
                        if(filterRegExes.length!=0){
                           
                            for(var j=0; j<filterRegExes.length; j++) {
                                    if(filterRegExes[j].test(evt.getIcon()) == true){ //changed to getIcon
                                        return true;
                                    }
                            }
                        }
                        else if(filterRegExes.length==0){
                            return true;
                        }    
                   return false;
                };
    }
   
    var regexes = [];
    var hasHighlights = false;
    for (var x = 0; x < theme.event.highlightColors.length; x++) {
        var tr = div.childNodes[1].childNodes[1].firstChild.rows[x];// wander through DOM to table
        var input = tr.cells[0].firstChild;
        var text2 = cleanString(input.value);
        if (text2.length > 0) {
            hasHighlights = true;
            regexes.push(new RegExp(text2, "i"));
        } else {
            regexes.push(null);
        }
    }
    var highlightMatcher = hasHighlights ? function(evt) {
        var text = evt.getText();
        var description = evt.getDescription();
        for (var x = 0; x < regexes.length; x++) {
            var regex = regexes[x];
            //if (regex != null && (regex.test(text) || regex.test (description))) {
            if (regex != null && regex.test(text)) {
                return x;
            }
        }
        return -1;
    } : null;
   
    // Set the matchers and repaint the timeline
    filterMatcherGlobal = filterMatcher;
    highlightMatcherGlobal = highlightMatcher;   
    for (var i = 0; i < bandIndices.length; i++) {
        var bandIndex = bandIndices[i];
        timeline.getBand(bandIndex).getEventPainter().setFilterMatcher(filterMatcher);
        timeline.getBand(bandIndex).getEventPainter ().setHighlightMatcher(highlightMatcher);
    }
    timeline.paint();
}



function clearAll(timeline, bandIndices, table) {
    var tr = table.rows[0];
    
    // First clear the filters
    for (var x = 0; x < tr.cells.length; x++) {
        
	tr.cells[0].firstChild.value = "";
    }
   
    // Then clear the highlights
    var tr = table.rows[3];
    for (var x = 0; x < tr.cells.length; x++) {
        tr.cells[x].firstChild.value = "";
    }
   
    // Then re-init the filters and repaint the timeline
    for (var i = 0; i < bandIndices.length; i++) {
        var bandIndex = bandIndices[i];
        timeline.getBand(bandIndex).getEventPainter().setFilterMatcher(null);
        timeline.getBand(bandIndex).getEventPainter().setHighlightMatcher(null);
    }
    timeline.paint();
}

// clearAll hack for Category Filtering, maybe better integrated in clearAll funtion
function clearCatAll(timeline, bandIndices, div, theme) {
   
    // First clear the filters
    for (var x = 0; x < numOfFilters; x++) {
        var tr = div.firstChild.childNodes[1].firstChild.rows[x];// wander through DOM to table
        tr.cells[0].firstChild.checked = "checked";
    }
   
    // Then clear the highlights
    for (var x = 0; x < theme.event.highlightColors.length; x++) {
        var tr = div.childNodes[1].childNodes[1].firstChild.rows[x]; // wander through DOM to table;
        tr.cells[0].firstChild.value = "";
    }
   
    // Then re-init the filters and repaint the timeline
    for (var i = 0; i < bandIndices.length; i++) {
        var bandIndex = bandIndices[i];
        timeline.getBand(bandIndex).getEventPainter().setFilterMatcher(null);
        timeline.getBand(bandIndex).getEventPainter().setHighlightMatcher(null);
    }
    timeline.paint();
}
