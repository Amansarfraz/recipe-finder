import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final int? cookTime;
  final double rating;
  final String? tag;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.title,
    this.imageUrl,
    this.cookTime,
    this.rating = 0.0,
    this.tag,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(height: 160, color: AppColors.primaryLight.withOpacity(0.3)),
                      errorWidget: (c, u, e) => Container(height: 160, color: AppColors.primaryLight.withOpacity(0.3)),
                    )
                  : Container(height: 160, color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: onFavoriteToggle,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: AppColors.primary, size: 20),
                ),
              ),
            ),
            if (cookTime != null)
              Positioned(
                bottom: 60,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                  child: Text('$cookTime min', style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(' ${rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (tag != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                        child: Text(tag!, style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
