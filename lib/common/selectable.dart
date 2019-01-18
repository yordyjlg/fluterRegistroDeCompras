class Selectable {
  var isSelect = false;

  void select() {
    this.isSelect = true;
  }

  void deselect() {
    this.isSelect = false;
  }
}