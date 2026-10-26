
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';
import '../../models/claim_model.dart';

class ClaimsOnMyItemsScreen extends StatefulWidget {
  const ClaimsOnMyItemsScreen({super.key});

  @override
  State<ClaimsOnMyItemsScreen> createState() =>
      _ClaimsOnMyItemsScreenState();
}

class _ClaimsOnMyItemsScreenState
    extends State<ClaimsOnMyItemsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final String? _userId;
  late final Stream<List<ClaimModel>>? _claimsStream;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _claimsStream = _userId == null
        ? null
        : _firestoreService.getClaimsOnMyItems(_userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claims on My Items'),
      ),
      body: _userId == null
          ? const Center(child: Text('Please sign in to continue.'))
          : StreamBuilder<List<ClaimModel>>(
              stream: _claimsStream,
              builder: (context, snapshot) {
              if (snapshot.hasError) {
                  debugPrint('CLAIMS ERROR: ${snapshot.error}');

                   return Center(
                     child: SingleChildScrollView(
                         padding: const EdgeInsets.all(20),
                         child: Text(
                           'Claims loading error:\n${snapshot.error}',
                           textAlign: TextAlign.center,
                          ),
                        ),
                     );
                   }
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final claims = snapshot.data ?? [];

                if (claims.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No claims on your items yet.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: claims.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final claim = claims[index];

                    return Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              claim.itemTitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(
                                claim.status.toUpperCase(),
                              ),
                            ),
                            const Divider(height: 24),
                            Text('Claimant: ${claim.claimantName}'),
                            const SizedBox(height: 6),
                            Text('Email: ${claim.claimantEmail}'),
                            const SizedBox(height: 6),
                            Text('Phone: ${claim.claimantPhone}'),
                            const SizedBox(height: 12),
                            const Text(
                              'Proof of ownership',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              claim.proofDescription.isEmpty
                                  ? 'No proof description provided.'
                                  : claim.proofDescription,
                            ),
                            if (claim.adminRemarks.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Admin remarks: ${claim.adminRemarks}',
                              ),
                            ],
                          ],
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
