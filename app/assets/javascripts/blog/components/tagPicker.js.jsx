var TagPicker = React.createClass({
  getInitialState: function() {
    return {
      tags_picked: this.props.initialData,
      error: null
    };
  },
  componentDidMount: function() {
    $('body').on('tags/create-tag', this.createTag);
    $('body').on('tags/select-a-tag', this.selectTag);

    this.next_tmp_id = -1;
  },
  componentWillUnmount: function() {
    $('body').off('tags/create-tag', this.createTag);
    $('body').off('tags/select-a-tag', this.selectTag);
  },
  updateTagId: function(tag_id, new_tag_id, new_tag_title) {
    var new_state = this.state;
    new_state['tags_picked'][new_tag_id] = new_state['tags_picked'][tag_id];
    new_state['tags_picked'][new_tag_id]['title'] = new_tag_title;
    delete new_state['tags_picked'][tag_id];
    this.setState(new_state);
  },
  updateTag: function(tag_id, data) {
    var old_data  = this.state['tags_picked'][tag_id];
    var new_state = this.state;

    if (!data) {
      delete new_state['tags_picked'][tag_id];
    }
    else {
      new_state['tags_picked'][tag_id] = data;
    }

    this.setState(new_state);
    return old_data;
  },
  createTag: function(e, tag_name) {
    var this_picker = this;
    var tag_id = this_picker.next_tmp_id--;
    this_picker.updateTag(tag_id, {title: tag_name, key: tag_id});

    $.ajax({
      type: "POST",
      url: this_picker.props.createUrl,
      dataType: "json",
      data: {
        tag: { title: tag_name }
      },
      context: tag_id,
      success: function(response) {
        var tag_id = this;
        var tag_data = this_picker.updateTagId(tag_id, response.tag_id, response.tag_title);
        this_picker.setState({error: null});
      },
      error: function(xhr, status, error_str) {
        var tag_id = this;
        var tag_data = this_picker.updateTag(tag_id, null);
        var error_message = "Please check your network connection";
        var response = xhr.responseJSON;
        if (response) {
          if (response.message) { error_message = response.message; }
          if (response.errors && response.errors.length > 0)  { error_message = response.errors.join(', ');  }
        }
        this_picker.setState({error: "Error: create tag '" + tag_data.title + "' failed. " + error_message});
      }
    });
  },
  selectTag: function(e, tag_id, tag_name) {
    this.updateTag(tag_id, {title: tag_name, key: tag_id});
  },
  removeTag: function(e, tag_id) {
    this.updateTag(tag_id, null);
  },
  render: function() {
    var tags = [];
    var this_picker = this;
    var tag_id_sort = function (a,b) {
      a = parseInt(a);
      b = parseInt(b);
      if (a < 0) {a = 1000000 + Math.abs(a)}
      if (b < 0) {b = 1000000 + Math.abs(b)}
      return b-a;
    };
    $.each(Object.keys(this_picker.state.tags_picked).sort(tag_id_sort), function (i, id) {
      var val = this_picker.state.tags_picked[id];
      if (val) {
        tags.push(<Tag title={val.title} key={val.key ? val.key : id} id={id} inputName={this_picker.props.inputName} callbackRemoveTag={this_picker.removeTag} />);
      }
    });

    return (
      <div className="tag-picker">
        <ul className="list-unstyled">
          {tags}
        </ul>
        {
          this_picker.state.error ?
            <div className="errorExplanation error_icon red">
              <p>{this_picker.state.error}</p>
            </div>
          : null
        }
      </div>
    );
  }
});

var $container = $('#tag-picker');
if ($container.length > 0) {
  React.render(
    <TagPicker
      inputName={$container.data('input-name')}
      createUrl={$container.data('create-url')}
      initialData={$container.data('initial-data')} />,
    $container[0]
  );
}
