import '../app_theme.dart';
import 'package:flutter/material.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _isAnnual = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg.withValues(alpha: 0.9),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: AppTheme.primary),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lumina AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text('Pricing Profile', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary)),
              ],
            ),
            Spacer(),
            IconButton(icon: Icon(Icons.notifications, color: AppTheme.textSecondary), onPressed: () {}),
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Alex+Morgan&background=006A62&color=fff'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // Header
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.highlight.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: AppTheme.primary),
                    SizedBox(width: 4),
                    Text('UNLOCK TIER-1 RECRUITER ACCESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Accelerate Your\nAI Trajectory', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, height: 1.1), textAlign: TextAlign.center),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text('Choose the career plan engineered to bridge skill gaps, benchmark your portfolio, and fast-track interviews with top tech teams.', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            ),
            SizedBox(height: 24),
            
            // Switcher
            Container(
              margin: EdgeInsets.symmetric(horizontal: 48),
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: AppTheme.highlight.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: !_isAnnual ? AppTheme.cardBg : Colors.transparent, borderRadius: BorderRadius.circular(24), boxShadow: !_isAnnual ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : []),
                        child: Center(child: Text('Monthly', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: !_isAnnual ? AppTheme.primary : AppTheme.textSecondary))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isAnnual = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: _isAnnual ? AppTheme.cardBg : Colors.transparent, borderRadius: BorderRadius.circular(24), boxShadow: _isAnnual ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : []),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Annual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _isAnnual ? AppTheme.primary : AppTheme.textSecondary)),
                            SizedBox(width: 4),
                            Container(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), decoration: BoxDecoration(color: AppTheme.purpleHighlight, borderRadius: BorderRadius.circular(8)), child: Text('-30%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText))),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // Carousel
            SizedBox(
              height: 650,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFreeCard(),
                  SizedBox(width: 16),
                  _buildPremiumCard(),
                  SizedBox(width: 16),
                  _buildCollegeCard(),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // Trust Badges
            Text('TRUSTED BY 14,000+ CANDIDATES HIRED AT TOP TECH LABS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.subtle.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(children: [Icon(Icons.account_balance, size: 20, color: AppTheme.grey), SizedBox(width: 4), Text('IIT Madras', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey))]),
                      Row(children: [Icon(Icons.token, size: 20, color: AppTheme.grey), SizedBox(width: 4), Text('BITS Pilani', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey))]),
                      Row(children: [Icon(Icons.psychology, size: 20, color: AppTheme.grey), SizedBox(width: 4), Text('Stanford', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.grey))]),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppTheme.highlight),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSecurityItem(Icons.verified_user, 'SOC-2 Certified'),
                      _buildSecurityItem(Icons.lock, 'AES-256 Encryption'),
                      _buildSecurityItem(Icons.school, 'FERPA Compliant'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            
            // FAQ
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help, color: AppTheme.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Can I switch, pause, or cancel anytime?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        SizedBox(height: 8),
                        Text('Yes, you can upgrade, downgrade, or cancel directly from your profile settings with zero friction. If you cancel during your billing cycle, you retain full Tier-1 placement perks and AI access until the cycle expires.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeCard() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.subtle, borderRadius: BorderRadius.circular(12)), child: Text('STARTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary))),
              Icon(Icons.explore, color: AppTheme.grey),
            ],
          ),
          SizedBox(height: 16),
          Text('Free Basic', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 4),
          Text('Core discovery tools for students exploring AI careers.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹0', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(width: 4),
              Text('/ month', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppTheme.subtle),
          ),
          _buildCheckItem('Basic Skill-Gap Radar Analysis'),
          SizedBox(height: 12),
          _buildCheckItem('Browse 1,000+ Curated Job Postings'),
          SizedBox(height: 12),
          _buildCheckItem('Standard Lumina Community Access'),
          SizedBox(height: 12),
          _buildCheckItem('1 AI Resume Parse per month'),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: null,
              icon: Icon(Icons.radio_button_checked, size: 18),
              label: Text('Current Plan', style: TextStyle(fontSize: 14)),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.subtle,
                disabledForegroundColor: AppTheme.textSecondary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: 320,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.tertiary, width: 2),
        boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.purpleHighlight, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.bolt, size: 12, color: AppTheme.deepPurpleText), SizedBox(width: 4), Text('MOST POPULAR • 3.4X FASTER HIRED', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText))])),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Text('Premium Career Pro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(width: 6),
              Icon(Icons.stars, color: AppTheme.primary, size: 24),
            ],
          ),
          SizedBox(height: 4),
          Text('Complete AI interview prep and prioritized recruiter ATS drops.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(_isAnnual ? '₹2388' : '₹399', style: TextStyle(fontSize: 18, color: AppTheme.grey, decoration: TextDecoration.lineThrough)),
              SizedBox(width: 8),
              Text(_isAnnual ? '₹1668' : '₹199', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              SizedBox(width: 4),
              Text(_isAnnual ? '/ yr' : '/ mo', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          Text(_isAnnual ? 'Special Offer: 2 Months Free! (₹139/mo equivalent)' : 'Billed monthly • Cancel anytime', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppTheme.subtle),
          ),
          _buildCheckItemPro('Unlimited 24/7 AI Interview Drills & Mock Voice Tests'),
          SizedBox(height: 12),
          _buildCheckItemPro('Lumina Hexagonal Skill Rubric & Tier-1 Certs'),
          SizedBox(height: 12),
          _buildCheckItemPro('1-Click Fast Apply to Stripe, Anthropic & Figma ATS'),
          SizedBox(height: 12),
          _buildCheckItemPro('Full Multi-Vector Radar & Adaptive Dynamic Path'),
          SizedBox(height: 12),
          _buildCheckItemPro('Monthly 1:1 Industry Lead Portfolio Critiques'),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Text('Subscribe Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cardBg)),
              label: Icon(Icons.arrow_forward, size: 18, color: AppTheme.cardBg),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield, size: 12, color: AppTheme.primary),
              SizedBox(width: 4),
              Text('7-day money-back guarantee', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollegeCard() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.purpleHighlight, borderRadius: BorderRadius.circular(12)), child: Text('CAMPUS & UNIVERSITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText))),
              Icon(Icons.school, color: AppTheme.secondary),
            ],
          ),
          SizedBox(height: 16),
          Text('College Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          SizedBox(height: 4),
          Text('Subsidized through university career centers & accredited student clubs.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('₹79', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              SizedBox(width: 4),
              Text('/ student / mo', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          Text('Valid active university credentials required', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: AppTheme.subtle),
          ),
          _buildCheckItemCollege('All Premium Career Pro Features included'),
          SizedBox(height: 12),
          _buildCheckItemCollege('University Cohort Benchmarks & Ranking'),
          SizedBox(height: 12),
          _buildCheckItemCollege('Campus Placement Showcase & Batch Drops'),
          SizedBox(height: 12),
          _buildCheckItemCollege('Official .edu or institutional verification'),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.badge, size: 18, color: AppTheme.deepPurpleText),
              label: Text('Verify Student ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.deepPurpleText)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.purpleHighlight,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 18, color: AppTheme.primary),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
      ],
    );
  }

  Widget _buildCheckItemPro(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.verified, size: 18, color: AppTheme.tertiary),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
      ],
    );
  }

  Widget _buildCheckItemCollege(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, size: 18, color: AppTheme.secondary),
        SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: AppTheme.textPrimary))),
      ],
    );
  }

  Widget _buildSecurityItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.primary),
        SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}
