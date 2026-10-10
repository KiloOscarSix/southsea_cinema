import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/models/movie.dart';

const double _posterWidth = 80;
const double _posterHeight = 120;

class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, required this.onBook});

  final Movie movie;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cinemaSurface,
      margin: const EdgeInsets.symmetric(
        horizontal: cinemaSpacingMedium,
        vertical: cinemaSpacingSmall,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(cinemaCornerRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(cinemaSpacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(movie.title.toUpperCase(), style: cinemaTitleStyle),
                      Text('(${movie.rating})', style: cinemaRatingStyle),
                      const SizedBox(height: cinemaSpacingSmall),
                      Text(movie.description, style: cinemaBodyStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: cinemaSpacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(movie.screeningTime, style: cinemaHeaderStyle),
                FilledButton(
                  onPressed: onBook,
                  child: Text('Book'.toUpperCase()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
