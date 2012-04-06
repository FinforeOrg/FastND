/*
 * FinFore.net 
 * Models
 *
 */
 
/* Extend Model.List.Local to fix LocalStorage issues */
$.Model.List.extend('jQuery.Model.List.Local', {
	retrieve : function(name){
		// each also needs what they are referencd by ?
		var props = $.evalJSON(Storage.getItem( name )) || { type: null, ids: [] };
			instances = [],
			Class = props.type ? $.String.getObject(props.type) :  null;
		
		
		for(var i =0; i < props.ids.length;i++){
			var identity = props.ids[i],
				instanceData = $.evalJSON( Storage.getItem( identity ) );
			instances.push( new Class(instanceData) )
		}
		this.push.apply(this,instances);
		return this;
	},
	store : function(name){
		//  go through and listen to instance updating
		var ids = [], days = this.days;
		this.each(function(i, inst){
			Storage.setItem(inst.identity(), $.toJSON(inst.attrs()));
			ids.push(inst.identity());
		});
		
		Storage.setItem(name, $.toJSON({
			type: this[0] && this[0].Class.fullName,
			ids: ids	
		}));
		return this;
	}
});

/**
 * User Model
 */
$.Model.extend('User', {
	/**
	 * Destroys a single todo by id
	 *     
	 *     Todo.destroy(1, success())
	 */
	destroy: function(id, success){
		// web service
	
		this.List.destroy([id], success);
	},
	/**
	 * Creates a todo with the provided attrs.  This allows:
	 * 
	 *     new Todo({text: 'hello'}).save( success(todo) );
	 */
	create: function(attrs, success){
		// TODO
		// USE WEB SERVICE METHOD HERE
		// USE ATTRS.LOCAL TO DETERMINE IF REQUEST SHOULD BE ONLY LOCAL
		
		// sau fa methoda identica, fara web service, createLocal
		// si o apelezi ca model.createLocal? CRED
		
		// sau converteste cumva obiectu in lista, stocheaza in localstorage si scoate-l iara
		
		console.log('create-user');
		
		success({id : attrs.id});
		
		return this;
	},
	/**
	 * Updates a todo by id with the provided attrs.  This allows:
	 * 
	 *     todo.update({text: 'world'}, success(todos) )
	 */
	update: function(id, attrs, success){
		// web service
		
		// update storage
		Users.store('User');
		
		success({});
	}

}, {});

/**
 * Helper methods on collections of todos.  But lists can also use their model's 
 * methods.  Ex:
 * 
 *   var todos = [new Todo({id: 5}) , new Todo({id: 6})],
 *       list = new Todo.List(todos);
 *       
 *   list.destroyAll() -> calls Todo.destroyAll with [5,6].
 */
$.Model.List('User.List', {}, {
	/**
	 * Return a new Todo.List of only complete items
	 */
	completed : function(){
		return this.grep(function(item){
			return item.complete === true;
		})
	}
});

$.Model.List.Local('User.List');

//var contacts = new User.List([]).retrieve("test");

// MERE new User.List(finfore.data.user.feed_accounts) da nu face trigger la add, cred

/*
finfore.data.user.feed_accounts[0].id = 0 ;
contacts = new User.List(finfore.data.user.feed_accounts);
*/

/*
var Users,
	loggedIn = Storage.getItem('User');

if(loggedIn) {
	
	console.log('stored');
	// get the data from storage
	Users = new User.List([]).retrieve('User');
	
	Users.bind('add', function(ev, item) {
		console.log('add')
		console.log(item);
		
		Users.store('User');
	});

	Users.bind('remove', function(ev, item) {
		console.log('remove')
		console.log(item);
		
		Users.store('User');
	});

	//add it to the list of contacts 
	Users.push([
		new User({
			id: 0,
			text: 'User'
		})
	]);

};

Users.get(0)[0].update({
	text: 'zer'
});
*/