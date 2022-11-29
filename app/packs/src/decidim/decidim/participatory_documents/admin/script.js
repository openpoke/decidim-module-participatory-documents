import { PDFAnnotate } from "./pdfannotate";

global.pdf = null;
//global.zoomScale = 1;
//global.outputJson = {e};

global.renderPDF = function() {
  pdf = new PDFAnnotate('pdf-container', documentUrl, {
    onPageUpdated(page, oldData, newData) {
      console.log(page, oldData, newData);
    },
    ready() {
      console.log('Plugin initialized successfully');
      pdf.loadFromJSON(outputJson || {});
    },
    scale: zoomScale || 1
  });
}

global.showVal = function(a) {
  pdf.serializePdf(function (string) {
    outputJson = JSON.parse(string);
  });
  zoomScale = Number(a);
  renderPDF();
  // $('#pdf-container').css("zoom", Number(a));
}

global.changeActiveTool = function(event) {
  var element = $(event.target).hasClass('tool-button')
    ? $(event.target)
    : $(event.target).parents('.tool-button').first();
  $('.tool-button.active').removeClass('active');
  $(element).addClass('active');
}

global.enableSelector = function(event) {
  event.preventDefault();
  changeActiveTool(event);
  pdf.enableSelector();
}

global.enableRectangle = function(event) {
  event.preventDefault();
  changeActiveTool(event);
  pdf.enableRectangle(function () {
    $('.tool-button').first().find('i').click();
  });
}

global.deleteSelectedObject = function(event) {
  event.preventDefault();
  pdf.deleteSelectedObject();
}

global.showPdfData = function() {
  pdf.serializePdf(function (string) {
    $('#dataModal .modal-body pre')
      .first()
      .text(JSON.stringify(JSON.parse(string), null, 4));
    $('#dataModal').modal('show');
  });
}


global.savePDF = function(url) {
  pdf.savePdf(url);
}



$(function () {
  renderPDF();

  $('.color-picker').minicolors({
    control: $('.color-picker').attr('data-control') || 'hue',
    defaultValue: $('.color-picker').attr('data-defaultValue') || '',
    format: $('.color-picker').attr('data-format') || 'hex',
    keywords: $('.color-picker').attr('data-keywords') || '',
    inline: $('.color-picker').attr('data-inline') === 'true',
    letterCase: $('.color-picker').attr('data-letterCase') || 'lowercase',
    opacity: $('.color-picker').attr('data-opacity'),
    position: $('.color-picker').attr('data-position') || 'bottom',
    swatches: $('.color-picker').attr('data-swatches') ? $('.color-picker').attr('data-swatches').split('|') : [],
    change: function(hex, opacity) {
      pdf.setColor(hex ? hex : 'transparent');
    },
    theme: 'default'
  });
//
//  $('#brush-size').change(function () {
//    var width = $(this).val();
//    pdf.setBrushSize(width);
//  });
//
//  $('#font-size').change(function () {
//    var font_size = $(this).val();
//    pdf.setFontSize(font_size);
//  });
});

