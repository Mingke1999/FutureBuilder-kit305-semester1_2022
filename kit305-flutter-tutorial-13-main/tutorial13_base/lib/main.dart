import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'movie_details.dart';
import 'movie.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //added this line
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
      options: FirebaseOptions(
      apiKey: "AIzaSyDi_aNBYWUYT8uoMWiSGjbSjDgp9TcSXdw",
      authDomain: "kit305-607-ad43a.firebaseapp.com",
      projectId: "kit305-607-ad43a",
      storageBucket: "kit305-607-ad43a.appspot.com",
      messagingSenderId: "272009876074",
      appId: "1:272009876074:web:e360828dc484b633e63013",
      measurementId: "G-MLCYZ82LKP"
  ));

  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder( //rendering our app until Firebase is initialized
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) //this function is called every time the "future" updates
      {
        // Check for errors
        if (snapshot.hasError) {
          return FullScreenText(text:"Something went wrong");
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done)
        {
          //BEGIN: the old MyApp builder from last week
          return ChangeNotifierProvider(
              create: (context) => MovieModel(),
              child: MaterialApp(
                  title: 'Database Tutorial',
                  theme: ThemeData(
                    primarySwatch: Colors.amber,
                  ),
                  home: MyHomePage(title: 'Database Tutorial')
              )
          );
          //END: the old MyApp builder from last week
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return FullScreenText(text:"Loading");
      },
    );
  }
}


class MyHomePage extends StatefulWidget
{
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
{
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieModel>(
        builder:buildScaffold
    );
  }

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(context: context, builder: (context) {
            return MovieDetails();
          });
        },
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (movieModel.loading) CircularProgressIndicator() else Expanded(
              child: ListView.builder(
                  itemCount: movieModel.items.length,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemBuilder: (_, index){

                var movie = movieModel.items[index];
                var image = movie.image;
                return Dismissible(

                  background: Container(color: Colors.deepPurple,),
                  key: ValueKey<int>(index),
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      movieModel.delete(movie.id);
                    });
                  },
                  child: ListTile( //movie list
                    title: Text(movie.title),
                    subtitle: Text(
                        movie.year.toString() + " - " + movie.duration.toString() +
                            " Minutes"),
                    leading: image != null ? Image.network(image) : null,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return MovieDetails(id: movie.id);
                          }));
                    },
                  )
                );
              }),

              ),
          ],
        ),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;
  const FullScreenText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection:TextDirection.ltr, child: Column(children: [ Expanded(child: Center(child: Text(text))) ]));
  }
}


  // Create the initialization Future outside of `build`:
  final Future<String> Function() test = () async
  {
    //wait some time
    await Future.delayed(Duration(seconds: 5));

    //then return the result
    return "done!";
  };

  @override
  Widget build(BuildContext context)
  {
    return FutureBuilder<String>(
      // Initialize FlutterFire:
      future: test(),
      builder: (context, snapshot) //this function is called every time the "future" updates
      {
        if (snapshot.hasData == false)
          return FullScreenText(text:"Loading...");
        return FullScreenText(text:snapshot.data!);
      },
    );
  }
}
