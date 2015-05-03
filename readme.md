#Práctica Cloud Computing
Repositorio de la práctica de Cloud Computing - **"Scoops" para iOS.**

Se ha montado en Azure un **Mobile Service** con una tabla *news* en la que se almacenan los scoops que escriben los usuarios de tipo *writter* a través del cliente móvil.

La tabla **news** consta de los siguientes campos:

- id
- title
- author
- authorID
- status
- latitude
- longitude
- numberofscores
- score
- image
- __createdAt
- __updatedAt
- __version
- __deleted

Se detallan a continuación las APIs del lado del servidor de Azuere que se han implementado:

##API - getcurrentuserinfo

API que descarga los datos de login del usuario logueado por Facebook:

	exports.get = function(request, response) {
	    request.user.getIdentities({
	        success: function (identities) {
	            var http = require('request');
	            console.log('Identities: ', identities);
	            var url = 'https://graph.facebook.com/me?fields=id,name,birthday,hometown,email,picture,gender,friends&access_token=' +
	                identities.facebook.accessToken;

	            var reqParams = { uri: url, headers: { Accept: 'application/json' } };
	            http.get(reqParams, function (err, resp, body) {
	                var userData = JSON.parse(body);
	                console.log('Logado -> ' + userData.name);
	                response.send(200, userData);
	            });
	        }
	    });
	};

##API - readallpartialnews

API que descarga los datos necesarios para popular la vista de a tabla con todas las noticias publicadas:

    exports.get = function(request, response) {
    
        var orderedBy = request.query.orderedBy;
        var status = request.query.status;
        var querySQL = "Select title, author, __updatedAt, id, authorID, image from news where status = '" + status + "'";
    
        var mssql = request.service.mssql;
    
        mssql.query(querySQL, {
        
            success:function(result){
                response.send(200, result.sort(function(a, b){
                    var keyA = new Date(a[orderedBy]);
                    var keyB = new Date(b[orderedBy]);
                    if(keyA < keyB) return 1;
                    if(keyA > keyB) return -1;
                    return 0;
                }));
	        },
	        error:function(error){
	            response.error(error);
	        }
	    });
	};

	function sortByKey(array, key) {
	    return array.sort(function(a, b) {
	        var x = a[key]; 
	        var y = b[key];
	        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	    });
	}

##API - readmynews

API que descarga los datos necesarios para popular las vistas de las tablas con todas las noticias de un autor *(modo "writter")*. Recibe como parámetro en la query también el *"status"* de las noticias que se quieren consultar:

	exports.get = function(request, response) {
	    
	    var orderedBy = request.query.orderedBy;
	    var status = request.query.status;
	    var authorID = request.query.authorID;
	    var querySQL = "Select title, author, __updatedAt, id, authorID, image, score from news where status = '" + status + "' and authorID = '" + authorID + "'";
	    
	    var mssql = request.service.mssql;
	    
	    mssql.query(querySQL, {
	        
	        success:function(result){
	            response.send(200, result.sort(function(a, b){
	                var keyA = new Date(a[orderedBy]);
	                var keyB = new Date(b[orderedBy]);
	                if(keyA < keyB) return 1;
	                if(keyA > keyB) return -1;
	                return 0;
	            }));
	        },
	        error:function(error){
	            response.error(error);
	        }
	    });
	};

	function sortByKey(array, key) {
	    return array.sort(function(a, b) {
	        var x = a[key]; 
	        var y = b[key];
	        return ((x < y) ? -1 : ((x > y) ? 1 : 0));
	    });
	}
	
##API - readonefullnew

API que descarga todos los datos de una noticia concreta (para rellenar la vista de detalle de una noticia):

	exports.get = function(request, response) {
	    
	    var idNoticia = request.query.idNoticia;
	    var querySQL = "Select * from news where id = '" + idNoticia + "'";
	    
	    var mssql = request.service.mssql;
	    
	    mssql.query(querySQL, {
	        
	        success:function(result){
	            response.send(200, result);
	        },
	        error:function(error){
	            response.error(error);
	        }
	    })
	};
	
##API - updatestatus

API que actualiza el *"status"* de una noticia concreta (se utiliza para que un autor pueda publicar una noticia, la cual pasará al estado *pending*):

	exports.get = function(request, response) {
	    
	    var mssql = request.service.mssql;
	    var idNoticia = request.query.idNoticia;
	    var status = request.query.status;
	    var querySQL = "UPDATE news SET status = '" + status + "' WHERE id = '" + idNoticia + "'";
	    
	    mssql.query(querySQL, {
	        
	        success:function(result){
	            response.send(200, result);
	        },
	        error:function(error){
	            response.error(error);
	        }
	    });
	};
	
##API - writescore

API que actualiza el valor medio de las puntuaciones recibidas por una noticia cuando cualquier usuario la puntua y le devuelve dicho *nuevo valor medio* al usuario para que actualice la vista en el cliente.

Además, se encarga de enviar una notificación push al autor de la noticia con la puntuación recibida

	exports.get = function(request, response) {
	    
	    var idNoticia = request.query.idNoticia;
	    var score = parseInt(request.query.score);
	    console.log('score: ' + score);
	    var querySQL = "SELECT score, numberofscores, authorID, title from news where id = '" + idNoticia + "'";
	    var mssql = request.service.mssql;
	    
	    mssql.query(querySQL, {
	        
	        success:function(results){
	            var item = results[0];
	            
	            var scoreInDB = item['score'];
	            var numberOfScoresInDB = item['numberofscores'];
	            var authorID = item['authorID']; // para las notificaciones
	            
	            console.log('scoreInDB: ' + scoreInDB);
	            console.log('numberOfScoresInDB: ' + numberOfScoresInDB);
	            
	            var totalScoreInDB = scoreInDB * numberOfScoresInDB;
	            
	            console.log('totalScoreInDB: ' + totalScoreInDB);
	            
	            var newTotalScore = totalScoreInDB + score;
	            var newNumberOfScores = numberOfScoresInDB + 1;
	            
	            console.log('newTotalScore: ' + newTotalScore);
	            console.log('newNumberOfScores: ' + newNumberOfScores);
	           
	            var newScore = Number((newTotalScore/newNumberOfScores).toString().match(/^\d+(?:\.\d{0,2})?/));
	            
	            console.log('newScore: ' + newScore);
	            
	            //response.send(200, results);
	            
	            var querySQL = "UPDATE news SET score = '" + newScore + "', numberOfScores = '"+ newNumberOfScores  + "' WHERE id = '" + idNoticia + "'";
	            mssql.query(querySQL, {
	                success:function(result){
	                    response.json({ score: newScore });
	                    setTimeout(function() {
	                        var push = request.service.push;
	                        push.apns.send(authorID, {
	                            alert: {
	                                title : "Nueva puntuación recibida",
	                                body : "Tu scoop '" + item['title'] + "' ha recibido " + score + " puntos."
	                            }
	                        });
	                    }, 2500);
	                },
	                error:function(error){
	                    response.error(error);
	                }
	            });
	        },
	        error:function(error){
	            response.error(error);
	        }
	    });
	};
	
##API - getbloburlfromauthorscontainer

API que devuelve la URL para un blob con un nombre conocido (*blobName*) que se encuentra dentro de un container conocido (*containerName*), en nuestro caso, el container correspondiente al autor de una noticia:

	var azure = require('azure');
	var qs = require('querystring');
	var appSettings = require('mobileservice-config').appSettings;

	exports.get = function(request, response) {

	    // en el parametro nos llega el nombre del blob
	    var blobName = request.query.blobName;
	    var containerName = request.query.containerName;
	    
	    // nombre del storage al que vamos acceder
	    var accountName = '******';
	    //var accountName = appSettings.STORAGE_ACCOUNT_NAME;
	    
	    // clave de acceso al storage
	    var accountKey = '****************';
	    //var accountKey = appSettings.STORAGE_ACCOUNT_ACCESS_KEY;
	    
	    var host = accountName + '.blob.core.windows.net/'
	    
	    var blobService = azure.createBlobService(accountName, accountKey, host);
	    
	    blobService.createContainerIfNotExists(containerName, {publicAccessLevel : 'blob'}, function(error){
	        if(!error){
	            // Container exists and is public
	            var sharedAccessPolicy = { 
	                AccessPolicy : {
	                    Permissions: 'rw', 
	                    Expiry: minutesFromNow(15)
	                }
	            };
	    
	            var sasURL = blobService.generateSharedAccessSignature(containerName, blobName, sharedAccessPolicy);
	    
	            console.log('SAS ->' + sasURL);
	    
	            var sasQueryString = { 'sasUrl' : sasURL.baseUrl + sasURL.path + '?' + qs.stringify(sasURL.queryString) };
	            request.respond(200, sasQueryString);
	        }
	    });   
	};

	function formatDate(date) { 
	    var raw = date.toJSON(); 
	    // Blob service does not like milliseconds on the end of the time so strip 
	    return raw.substr(0, raw.lastIndexOf('.')) + 'Z'; 
	} 

	function minutesFromNow(minutes) {
	    var date = new Date()
	  date.setMinutes(date.getMinutes() + minutes);
	  return date;
	}
	
##Job - publishnews

Job que se ejecuta cada 2 horas y que se encarga de publicar definitivamente (*published*) los scoops que se encontraban en estado *pending* (el writter ya las había publicado desde el cliente móvil). Se habilitarán dichos scoops para la lectura por parte de los usuarios no logueado:

	function publishNews() {
	    console.warn("You are running an empty scheduled job. Update the script for job 'publishNews' or disable the job.");
	    
	    var querySQL = "UPDATE news SET status = 'published' WHERE status = 'pending'";
	    
	    mssql.query(querySQL, {
	        
	        success:function(result){
	            console.log('noticias publicadas');
	        },
	        error:function(error){
	            console.log('error al publicar noticias');
	        }
	    });
	}