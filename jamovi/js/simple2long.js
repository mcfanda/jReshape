const events = {
   colstorows_changed: function(ui) {
     ui.create.setValue(false);
   },
   covs_changed: function(ui) {
     ui.create.setValue(false);
   },
   rmlevels_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   dep_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   filename_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   open_changed: function(ui) {
     ui.create.setValue(false);
   }

};

module.exports = events;

    

