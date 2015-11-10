var Tag= React.createClass({
  removeTag: function(e) {
    this.props.callbackRemoveTag(e, this.props.id)
  },
  render: function() {
    return (
      <li>
        {this.props.title} <button onClick={this.removeTag}><i className="icon icon-close"></i></button>
        {parseInt(this.props.id) > 0 ? <input type="hidden" name={this.props.inputName} value={this.props.id}></input> : null}
      </li>
    );
  }
});
