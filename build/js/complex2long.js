const moveup=0;
const movedown=0;
const bound=2000000;

const events = {
  
    onChange_items_changed: function(ui) {
      
    },
    onChange_items_changed: function(ui) {
      
    },
    
   onChange_index_added: function(ui) {
      
      var h = ui.index.$el.height();
      ui.index.$el.height(h+moveup)
      updateStructure(ui,this);
      
    },
    onChange_index_removed: function(ui) {
      
      var h = ui.index.$el.height();
      if (h>bound)
          ui.index.$el.height(h-movedown)
      updateStructure(ui,this);
      
    },

  
   colstorows_changed: function(ui) {
     ui.create.setValue(false);
     const newvals=ui.colstorows.value().map(e) => 
     { 
       if (typeof element === 'undefined') {
            return replacement;
        }
       return element;
     }
     console.log(newvals);
   },
   covs_changed: function(ui) {
     ui.create.setValue(false);
   },
   index_changed: function(ui) {
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

    
const updateStructure=function(ui, obj) {
};

