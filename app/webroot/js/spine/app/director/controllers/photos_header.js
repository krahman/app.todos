var $, PhotosHeader;
var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
  for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
  function ctor() { this.constructor = child; }
  ctor.prototype = parent.prototype;
  child.prototype = new ctor;
  child.__super__ = parent.prototype;
  return child;
};
if (typeof Spine === "undefined" || Spine === null) {
  Spine = require("spine");
}
$ = Spine.$;
PhotosHeader = (function() {
  __extends(PhotosHeader, Spine.Controller);
  PhotosHeader.extend(Spine.Controller.Drag);
  PhotosHeader.prototype.events = {
    'click .closeView .gal': 'backToGalleries',
    'click .closeView .alb': 'backToAlbums',
    'dragenter': 'dragenter',
    'dragover': 'dragover',
    'dragend': 'dragend'
  };
  function PhotosHeader() {
    PhotosHeader.__super__.constructor.apply(this, arguments);
  }
  PhotosHeader.prototype.backToGalleries = function() {
    console.log('PhotosHeader::closeView');
    return Spine.trigger('show:galleries');
  };
  PhotosHeader.prototype.backToAlbums = function() {
    console.log('PhotosHeader::closeView');
    return Spine.trigger('show:albums');
  };
  PhotosHeader.prototype.change = function(item) {
    this.current = item;
    return this.render();
  };
  PhotosHeader.prototype.render = function() {
    return this.html(this.template({
      gallery: Gallery.record,
      record: this.current,
      count: this.count()
    }));
  };
  PhotosHeader.prototype.count = function() {
    if (Album.record) {
      return AlbumsPhoto.filter(Album.record.id, {
        key: 'album_id'
      }).length;
    } else {
      return Photo.all().length;
    }
  };
  return PhotosHeader;
})();
if (typeof module !== "undefined" && module !== null) {
  module.exports = PhotosHeader;
}