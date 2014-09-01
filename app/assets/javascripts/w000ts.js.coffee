# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Define a jQuery sub that will select the text of a div
$ = jQuery
$.fn.selectText = ->
  doc = document;
  element = this[0];
  if (doc.body.createTextRange)
    range = document.body.createTextRange();
    range.moveToElementText(element);
    range.select();
  else if window.getSelection
    selection = window.getSelection();
    range = document.createRange();
    range.selectNodeContents(element);
    selection.removeAllRanges();
    selection.addRange(range);
