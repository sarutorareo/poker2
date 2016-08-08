// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the rails generate channel command.
//
//= require action_cable
//= require_self
// 2016/08/08 require tree ./channels では、app/assets/javascript以下のすべてのjsが読まれてしまう。その場合、channel describeが望むタイミングで読まれないため、require tree ./channels をやめて、個別に読み込む    
// require_tree ./channels

(function() {
  this.App || (this.App = {});

  App.cable = ActionCable.createConsumer();

}).call(this);
