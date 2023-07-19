const events = {
    update: function(ui) {
      console.log("updating");
      ui.create.setValue(false);
    },
    button_creating: function(ui) {
     let $contents=ui.button.$el;
  		$contents.append(`
		    <div id="createbutton" style="padding: 10px; ">
 	     <input id="inputbutton" type="submit" value="Reshape" style="color: green; font-size: 1.8em; font-weight: bold; padding: 5px 15px 5px 15px" >
        </div>`);
     $contents.on("click", () =>  {
          ui.create.setValue(true);
     });
     ui.create.setValue(false);

     let $view=ui.view.$el;
     
     $view.mouseover(function () {
      ui.create.setValue(false);
     });
    },

};

module.exports = events;

    

