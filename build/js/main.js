const events = {
    update: function(ui) {
      console.log("updating");
      ui.create.setValue(false);
    },
    button_creating: function(ui) {
     let $contents=ui.button.$el;
  		$contents.append(`
		    <div id="createbutton" style="padding: 10px">
 	     <input type="submit" value="Create" style="color: green; font-size: 1.2em; font-weight: bold" >
        </div>`);
     $contents.on("click", () =>  {
          ui.create.setValue(true);
     });
    }

};

module.exports = events;

    

