import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/views/movie_listing.dart';

const double _posterWidth = 100;
const double _posterHeight = 150;

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cinemaBackground,
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: cinemaSpacingMedium,
        vertical: cinemaSpacingSmall,
      ),
      shape: const RoundedRectangleBorder(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: cinemaSpacingSmall,
            children: [
              Expanded(
                child: Text(
                  movie.title.toUpperCase(),
                  style: cinemaTitleStyle,
                ),
              ),
              Text('(${movie.ageRating})', style: cinemaMutedStyle),
            ],
          ),
          const SizedBox(height: cinemaSpacingMedium),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                movie.imagePath,
                width: _posterWidth,
                height: _posterHeight,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: cinemaSpacingMedium),
              Expanded(
                child: Text(movie.description, style: cinemaBodyStyle),
              ),
            ],
          ),
          const SizedBox(height: cinemaSpacingMedium),
          Text('Book tickets'.toUpperCase(), style: cinemaBodyStyle),
          const SizedBox(height: cinemaSpacingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(movie.screeningTime, style: cinemaBodyStyle),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MovieListing(movie: movie);
                    }),
                  );
                },
                child: Text('Book now'.toUpperCase()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
