/*Tutorial expres de como usar este archivo
dentro Routes que es privado se pone datos staticos constantes
tendran el nombre de variable de la ruta = '/nombreRuta'
 para luego ser importada en app_routes.dart
 y darle el contexto con su widget correspondiente
*/
class Routes {
  Routes._();

  static const selecctTypeAccount = '/selectTypeAccount';  static const preLogin = '/preLogin';  static const login_page = '/login';
  static const forgotPassword = '/forgotPassword';
  static const resetByCode = '/resetByCode';
  static const register_user_page = '/registerUser';
  static const splashFT1 = '/splashFT1';
  static const splashFT2 = '/splashFT2';
  static const splashFT3 = '/splashFT3';
  static const order_Success = '/orderSuccess';
  static const client_Form = '/clientForm';
  static const deliver_Form1 = '/deliverForm1';
  static const deliver_Form2 = '/deliverForm2';
  static const comerse_Form = '/comerseForm';
  static const driverPending = '/driverPending';
  static const merchantPending = '/merchantPending';  static const home_food = '/homeFood';
  static const home_merchant = '/homeMerchant';  static const home_driver = '/homeDriver';
  static const driver_order_details = '/driver/orderDetails';
  static const merchantStepBusiness = '/merchant/step1';
  static const merchantStepOwner = '/merchant/step2';
  static const merchantStepPassword = '/merchant/step3';
  static const merchantSettings = '/merchantSettings';
  static const addProduct = '/addProduct';
  static const editProduct = '/editProduct';
  static const product_Detail = '/productDetail';
  static const home_admin = '/adminHome';
  static const food_filter = '/foodFilter';
  static const merchantPublicProducts = '/merchantPublicProducts';
  static const searchFilter = '/searchFilter';
  static const clientNav = '/clientNav';
  static const isFirstTime = '/isFirstTime';
  static const appStartNavigation = '/appStartNavigation';
  static const editAddress = '/editAddress';
  static const selectUserRole = '/selectUserRole';
  static const roleFormPage = '/roleFormPage';
  static const addRolePage = '/addRolePage';
  static const carrito = '/carrito';
  static const pago = '/pago';
  static const UserBottomBarCustomer = '/userBottomBarCustomer';
  static const modifyCustomerInfo = '/modifyCustomerInfo';

  // Test route
  static const testImages = '/testImages';
}
