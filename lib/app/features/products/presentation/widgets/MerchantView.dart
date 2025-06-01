import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class MerchantView extends StatelessWidget {
  const MerchantView({
    super.key,
    required Future<List<Merchant>> merchantsFuture,
  }) : _merchantsFuture = merchantsFuture;

  final Future<List<Merchant>> _merchantsFuture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: FutureBuilder<List<Merchant>>(
        future: _merchantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay mercaderes disponibles.'));
          }

          final mercaderes = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 1.1,
            ),
            itemCount: mercaderes.length,
            itemBuilder: (context, index) {
              final mercader = mercaderes[index];

              return Card(
                margin: EdgeInsets.only(
                  left: index % 2 == 0 ? 0 : 8,
                  right: 8,
                  bottom: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 100,
                    child:
                        mercader.logoUrl != null
                            ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.merchantPublicProducts,
                                  arguments: mercader,
                                );
                              },
                              child: Image.network(
                                mercader.logoUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Text('No imagen suported'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
