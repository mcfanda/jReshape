const moveup=0;
const movedown=0;
const bound=2000000;

const events = {
  
    onChange_items_changed: function(ui) {
      
    },
    onChange_items_changed: function(ui) {
      
    },
    
   onChange_index_added: function(ui) {
      
      var h = ui.comp_index.$el.height();
      ui.comp_index.$el.height(h+moveup)
      updateStructure(ui,this);
      
    },
    onChange_index_removed: function(ui) {
      
      var h = ui.comp_index.$el.height();
      if (h>bound)
          ui.index.$el.height(h-movedown)
      updateStructure(ui,this);
      
    },

   onChange_items_changed: function(ui) {
  
     const newvals=ui.comp_colstorows.value().map((e, i) => { 
       if (e===null) {
            return {label: "long_y"+(i+1), vars: []};
        }
       if (e.label===null) {
            return e.label= "long_y"+(i+1);
        }
        
       return e;

     });
    console.log(newvals)

//     ui.colstorows.setValue(newvals);
   },
  
   sim_colstorows_changed: function(ui) {
     ui.create.setValue(false);
   },
   comp_colstorows_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   sim_covs_changed: function(ui) {
     ui.create.setValue(false);
   },
   comp_covs_changed: function(ui) {
     ui.create.setValue(false);
   },

   sim_index_changed: function(ui) {
     ui.create.setValue(false);
   },
   comp_index_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   sim_dep_changed: function(ui) {
     ui.create.setValue(false);
   },
   comp_dep_changed: function(ui) {
     ui.create.setValue(false);
   },
   
   mode_changed: function(ui) {
     ui.create.setValue(false);
   }


};

module.exports = events;

    
const updateStructure=function(ui, obj) {
};

