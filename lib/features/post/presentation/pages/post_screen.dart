import 'package:flutter/material.dart';
import 'package:list_in/features/post/presentation/pages/catalog_screen.dart';
import 'package:list_in/features/post/presentation/provider/post_provider.dart';
import 'package:provider/provider.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  bool calledFetch = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(
      builder: (context, provider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!calledFetch) {
            provider.fetchCatalogs();
            setState(() {
              calledFetch = true;
            });
          }
        });

        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Scaffold(
              body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => {
                  setState(
                    () {
                      calledFetch = false;
                    },
                  )
                },
                child: const Text('Reget'),
              ),
              Center(
                child: Text(provider.error!),
              ),
            ],
          ));
        }

        return const CatalogPagerScreen();
      },
    );
  }
}
//