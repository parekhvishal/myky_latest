import 'package:get/get.dart';
import 'package:myky_clone/mlm/auth_mlm/promoter_register.dart';
import 'package:myky_clone/mlm/auth_mlm/vendor_register.dart';
import 'package:myky_clone/mlm/dashboard/image_preview/image_preview.dart';
import 'package:myky_clone/mlm/near_by_offline_store_list/near_by_offline_store_list.dart';
import 'package:myky_clone/mlm/shop_complaints/create_ticket.dart';
import 'package:myky_clone/mlm/shop_complaints/ticket_detail.dart';
import 'package:myky_clone/mlm/wallet/coin_wallet_transactions.dart';
import 'package:myky_clone/mlm/wallet/pending_wallet_transaction.dart';

import '../../../../mlm/support/ticketCreate.dart';
import '../../../../mlm/vendor/vendor_invoice.dart';
import '../../../../shopping/best-seller/best_saller.dart';
import '../../../mlm/support/supportChat.dart';
import '../../../mlm/support/supportList.dart';
import '../../../mlm/vendor/offline_order.dart';
import '../../../mlm/vendor/qr_code_details.dart';
import '../../../mlm/vendor/vendor_map.dart';
import '../../../shopping/recharge/dth_recharge.dart';
import '../../../shopping/recharge/electricity_bill.dart';
import '../../../shopping/recharge/mobile_recharge.dart';
import '../../../shopping/recharge/rechargeSummary.dart';
import '../../../shopping/review/review-add.dart';
import '../../mlm/account/banking-partner.dart';
import '../../mlm/account/transactionChangePassword.dart';
import '../../mlm/auth_mlm/change-password.dart';
import '../../mlm/auth_mlm/supplier_register.dart';
import '../../mlm/auth_mlm/supplier_register_controller.dart';
import '../../mlm/introductory_video/introductory_video_list.dart';
import '../../mlm/my_banners/customer_customer.dart';
import '../../mlm/my_banners/customer_vendor.dart';
import '../../mlm/my_banners/vendor_customer.dart';
import '../../mlm/pin/pin_request.dart';
import '../../mlm/pin/pin_request_list.dart';
import '../../mlm/self_explanatory_video/self_explanatory_video_list.dart';
import '../../mlm/withdrawal/withdrawal_list.dart';
import '../../mlm/withdrawal/withdrawal_request.dart';
import '../../shopping/account/audio_settings.dart';
import '../../shopping/account/grievance.dart';
import '../../shopping/bank_details.dart';
import '../../shopping/cart-payment/payment_web_view.dart';
import '../../shopping/cart-payment/payments.dart';
import '../../shopping/cart-payment/thanks.dart';
import '../../shopping/languageVideo.dart';
import '../../shopping/order/completed_orders.dart';
import '../../shopping/order/guest_order_history.dart';
import '../../shopping/order/guest_order_tab.dart';
import '../../shopping/order/my_order_detail.dart';
import '../../shopping/order/product_return.dart';
import '../../shopping/order/return_orders.dart';
import '../../shopping/order/track_shipment.dart';
import '../../shopping/order/view_return_order.dart';
import '../../shopping/recharge/gas_bill.dart';
import '../../shopping/recharge/rechargeThanks.dart';
import '../../shopping/review/review-list.dart';
import '../../shopping/trending/trending_list.dart';
import '../../widget/photo_zoom.dart';
import '../MainFrontDashboard.dart';
import '../mlm/TopUp/TopUp-View.dart';
import '../mlm/TopUp/TopUp.dart';
import '../mlm/account/KYC-details.dart';
import '../mlm/account/ProfileScreen.dart';
import '../mlm/auth_mlm/foregtPassword.dart';
import '../mlm/auth_mlm/login_mlm.dart';
import '../mlm/auth_mlm/register.dart';
import '../mlm/dashboard/dashboard.dart';
import '../mlm/dashboard/upgrade_promotor.dart';
import '../mlm/genyology/mlm_genealogy.dart';
import '../mlm/income/income.dart';
import '../mlm/payout/payout.dart';
import '../mlm/payout/promoter_payout.dart';
import '../mlm/pin/pin_list.dart';
import '../mlm/reports/reports.dart';
import '../mlm/shop_complaints/support_ticket_list.dart';
import '../mlm/vendor_wallet_transaction/vendor_wallet_transaction_new.dart';
import '../mlm/wallet/wallet.dart';
import '../shopping/account/my_account.dart';
import '../shopping/app-services/appUpdateScreen.dart';
import '../shopping/app-services/apppMaintance.dart';
import '../shopping/app-services/no_internet.dart';
import '../shopping/cart-payment/cart.dart';
import '../shopping/category/category.dart';
import '../shopping/category/sub_category.dart';
import '../shopping/home_ecommerce.dart';
import '../shopping/notification/notification.dart';
import '../shopping/order/my_orders.dart';
import '../shopping/product/product_detail.dart';
import '../shopping/product/products.dart';
import '../shopping/product/search_page.dart';
import '../shopping/reward/reward.dart';
import '../shopping/wishlist/wishlist.dart';
import '../spalsh_logo.dart';
import '../video_player.dart';
import '../widget/pdf_viewer.dart';
import '../widget/something_went_wrong.dart';

class AppRouter {
  static List<GetPage> pages = [
    GetPage(name: '/', page: () => SplashLogo()),
    GetPage(name: '/no-internet', page: () => NoInternet()),
    GetPage(name: '/app-maintenance', page: () => const AppMaintenance()),
    GetPage(name: '/app-update', page: () => const AppUpdate()),
    GetPage(name: '/video-player', page: () => const VideoPlayer()),

    // MLM
    GetPage(
        name: '/something-went-wrong', page: () => const SomethingWentWrong()),
    GetPage(name: '/login-mlm', page: () => LoginMLM()),
    GetPage(name: '/register-mlm', page: () => Register()),
    GetPage(name: '/register-promoter', page: () => const PromoterRegister()),
    GetPage(name: '/register-vendor', page: () => const VendorRegister()),
    GetPage(
        name: '/register-supplier',
        page: () => SupplierRegister(),
        binding: RegisterBinding()),
    GetPage(name: '/forget-password-mlm', page: () => ForgotPassword()),
    GetPage(name: '/change-password', page: () => ChangePassword()),
    GetPage(name: '/profile-mlm', page: () => ProfileScreen()),
    GetPage(
        name: '/customer-to-customer', page: () => const CustomerToCustomer()),
    GetPage(name: '/customer-to-vendor', page: () => const CustomerToVendor()),
    GetPage(name: '/vendor-to-customer', page: () => const VendorToCustomer()),
    GetPage(name: '/top-up-mlm', page: () => TopUp()),
    GetPage(name: '/top-up-view-mlm', page: () => TopUpView()),
    GetPage(name: '/pin-list-mlm', page: () => PinList()),
    GetPage(name: '/kyc', page: () => KycDetails()),
    GetPage(name: '/dashboard', page: () => const Dashboard()),
    GetPage(name: '/reports', page: () => Reports()),
    GetPage(
        name: '/self-explanatory-video',
        page: () => const SelfExplanatoryVideo()),
    GetPage(name: '/introductory-video', page: () => const IntroductoryVideo()),
    GetPage(name: '/withdrawal-request-list', page: () => WithdrawalList()),
    GetPage(name: '/withdrawal-request', page: () => WithdrawalCreate()),
    GetPage(name: '/genealogy-mlm', page: () => MLMGenealogy()),
    GetPage(name: '/income-mlm', page: () => Incomes()),
    GetPage(name: '/banking-partner', page: () => BankingPartner()),
    GetPage(name: '/payout', page: () => Payout()),
    GetPage(name: '/promoter-payout', page: () => const PromoterPayout()),
    GetPage(name: '/wallet', page: () => Wallet()),
    GetPage(name: '/pending-wallet', page: () => PendingWallet()),
    GetPage(name: '/coin-wallet', page: () => const CoinWallet()),
    GetPage(name: '/pin-request', page: () => PinRequest()),
    GetPage(name: '/pin-request-list', page: () => PinRequestList()),
    GetPage(name: '/photo-zoom', page: () => PhotoZoom()),
    GetPage(
        name: '/transaction-change-password',
        page: () => TransactionChangePassword()),
    // GetPage(name: '/vendor-payout', page: () => VendorPayout()),
    GetPage(name: '/pdf-viewer', page: () => const PDFViewer()),
    GetPage(name: '/grievance-redressal', page: () => const Grievance()),
    // GetPage(
    //   name: '/vendor-wallet-transaction',
    //   page: () => VendorWalletTransactionNew(),
    // ),

    //Shopping
    GetPage(name: '/language-video', page: () => const LanguageVideo()),
    GetPage(name: '/ecommerce', page: () => HomeECommerce()),
    GetPage(name: '/category', page: () => Category()),
    GetPage(name: '/sub-category', page: () => SubCategory()),
    GetPage(name: '/product-list', page: () => ProductListing()),
    GetPage(name: '/product-detail', page: () => ProductDetail()),
    GetPage(name: '/search-page', page: () => SearchPage()),
    GetPage(name: '/wishlist', page: () => WishList()),
    GetPage(name: '/orders', page: () => MyOrders()),
    GetPage(name: '/return-orders', page: () => MyReturnOrders()),
    GetPage(name: '/view-return-order', page: () => const ViewReturnOrder()),
    GetPage(name: '/track-shipment', page: () => const TrackShipment()),
    GetPage(name: '/support', page: () => SupportList()),
    GetPage(name: '/support-chat', page: () => SupportChat()),
    GetPage(name: '/ticket-create', page: () => TicketCreate()),
    GetPage(name: '/my-order-detail', page: () => MyOrderDetail()),
    GetPage(name: '/product-return', page: () => const ProductReturn()),
    GetPage(name: '/account', page: () => const MyAccount()),
    GetPage(name: '/audio-settings', page: () => const AudioSettings()),
    GetPage(name: '/cart', page: () => CartPage()),
    GetPage(name: '/payment-web-view', page: () => PaymentWebView()),
    GetPage(name: '/trending-list', page: () => const TrendingList()),
    GetPage(name: '/best-seller-page', page: () => const BestSellerPage()),
    GetPage(name: '/notification', page: () => const Notification()),
    GetPage(name: '/review-list', page: () => const ReviewList()),
    GetPage(name: '/review-add', page: () => const ReviewAdd()),
    GetPage(name: '/payments', page: () => Payments()),
    GetPage(name: '/shopping-thanks', page: () => Thanks()),

    // Vendor
    GetPage(name: '/qr-view', page: () => const QRView()),
    GetPage(name: '/off-line-orders', page: () => const OffLineOrders()),
    GetPage(name: '/near-me-store', page: () => const NearMeStore()),
    GetPage(name: '/vendor-invoice', page: () => const VendorInvoice()),
    GetPage(
        name: '/vendor-wallet-transaction',
        page: () => const VendorWalletTransactionNew()),
    GetPage(
        name: '/nearby-offline-store',
        page: () => const NearByOfflineStoreList()),

    //-----Help Center-----//
    GetPage(name: '/help-support-list', page: () => const HelpCenterList()),
    GetPage(name: '/create-ticket', page: () => const CreateTicket()),
    GetPage(name: '/ticket-detail', page: () => const TicketDetails()),

    //Guest
    GetPage(name: '/bank-details', page: () => const BankDetails()),
    GetPage(name: '/guest-order-tab', page: () => const GuestOrderTab()),
    GetPage(
        name: '/guest-completed-orders',
        page: () => const GuestCompletedOrder()),
    GetPage(
        name: '/guest-order-history', page: () => const GuestOrderHistory()),

    // Recharge
    GetPage(name: '/dth-recharge', page: () => DthRecharge()),
    GetPage(name: '/electricity-bill', page: () => ElectricityBill()),
    GetPage(name: '/gas-cylinder', page: () => GasBill()),
    GetPage(name: '/mobile-recharge', page: () => MobileRecharge()),
    GetPage(name: '/recharge-summary', page: () => const RechargeSummary()),
    GetPage(name: '/recharge-thanks', page: () => const RechargeThanks()),
    GetPage(name: '/image-preview', page: () => const ImagePreview()),
    GetPage(name: '/upgrade-promoter', page: () => const UpgradePromoter()),

    //Reward
    GetPage(name: '/reward', page: () => const Reward()),

    // Main Dashboard
    GetPage(name: '/main-dashboard', page: () => MainFrontDashboard()),
  ];
}
