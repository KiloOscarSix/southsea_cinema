import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return const [
      Movie(
          id: "dracula",
          title: "Dracula",
          description:
              "The dashing, mysterious Count Dracula (Bela Lugosi) travels to London and takes up residence in an old castle. Soon he begins to wreak havoc, sucking the blood of young women and turning them into vampires. Van Helsing is enlisted to put a stop to the count's never-ending bloodlust.",
          imagePath: "assets/images/dracula.jpg",
          genre: "Dark Fantasy",
          duration: 74,
          rating: "PG"),
      Movie(
          id: "phantom-of-the-opera",
          title: "The Phantom of the Opera",
          description:
              "The deformed Phantom who haunts the Paris Opera House causes murder and mayhem in an attempt to make the woman he loves a star.",
          imagePath: "assets/images/phantom-of-the-opera.jpg",
          genre: "assets/image/phantom-of-the-opera.jpg",
          duration: 101,
          rating: "12A")
    ];
  }
}
