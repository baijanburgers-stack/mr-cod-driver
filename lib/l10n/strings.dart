import 'locale.dart';

String t(String key) =>
    AppStrings.s[key]?[localeNotifier.value.name] ?? key;

// Driver Translation Strings
class AppStrings {
  static const Map<String, Map<String, String>> s = {
    // General
    'appName':          {'en': 'MR COD Driver', 'fr': 'MR COD Livreur', 'nl': 'MR COD Bezorger'},
    'driverPortal':     {'en': 'Driver Portal', 'fr': 'Portail Livreur', 'nl': 'Bezorger Portaal'},

    // Login
    'startShift':       {'en': 'Start Your Shift', 'fr': 'Commencer votre service', 'nl': 'Begin uw dienst'},
    'startShiftBtn':    {'en': 'Start Shift', 'fr': 'Commencer', 'nl': 'Begin Dienst'},
    'enterDetails':     {'en': 'Enter your details to begin delivering', 'fr': 'Entrez vos informations pour commencer', 'nl': 'Voer uw gegevens in om te beginnen'},
    'yourName':         {'en': 'Your Name', 'fr': 'Votre nom', 'nl': 'Uw naam'},
    'nameHint':         {'en': 'e.g. Ahmed Karimi', 'fr': 'ex. Ahmed Karimi', 'nl': 'bijv. Ahmed Karimi'},
    'yourStore':        {'en': 'Your Store', 'fr': 'Votre magasin', 'nl': 'Uw winkel'},
    'enterName':        {'en': 'Please enter your name', 'fr': 'Veuillez entrer votre nom', 'nl': 'Voer uw naam in'},
    'selectStore':      {'en': 'Please select your store', 'fr': 'Veuillez sélectionner votre magasin', 'nl': 'Selecteer uw winkel'},

    // Home
    'online':           {'en': 'Online', 'fr': 'En ligne', 'nl': 'Online'},
    'onShift':          {'en': 'Driver • On Shift', 'fr': 'Livreur • En service', 'nl': 'Bezorger • In dienst'},
    'availableDeliveries': {'en': 'AVAILABLE DELIVERIES', 'fr': 'LIVRAISONS DISPONIBLES', 'nl': 'BESCHIKBARE LEVERINGEN'},
    'noDeliveries':     {'en': 'No deliveries yet', 'fr': 'Aucune livraison pour l\'instant', 'nl': 'Nog geen leveringen'},
    'noDeliveriesMsg':  {'en': 'Orders marked "Out for Delivery" will appear here', 'fr': 'Les commandes marquées "En livraison" apparaîtront ici', 'nl': 'Bestellingen "Onderweg" verschijnen hier'},
    'takeDelivery':     {'en': 'Take This Delivery', 'fr': 'Prendre cette livraison', 'nl': 'Neem deze levering'},
    'activeDelivery':   {'en': 'YOUR ACTIVE DELIVERY', 'fr': 'VOTRE LIVRAISON EN COURS', 'nl': 'UW ACTIEVE LEVERING'},
    'tapToOpen':        {'en': 'Tap to open →', 'fr': 'Appuyer pour ouvrir →', 'nl': 'Tik om te openen →'},

    // End shift
    'endShift':         {'en': 'End Shift?', 'fr': 'Terminer le service ?', 'nl': 'Dienst beëindigen?'},
    'endShiftMsg':      {'en': 'This will log you out of the driver portal.', 'fr': 'Cela vous déconnectera du portail livreur.', 'nl': 'Dit logt u uit het bezorgersportaal.'},
    'endShiftBtn':      {'en': 'End Shift', 'fr': 'Terminer', 'nl': 'Beëindigen'},
    'cancel':           {'en': 'Cancel', 'fr': 'Annuler', 'nl': 'Annuleren'},

    // Delivery screen
    'activeDeliveryTitle': {'en': 'Active Delivery', 'fr': 'Livraison en cours', 'nl': 'Actieve levering'},
    'live':             {'en': 'Live', 'fr': 'En direct', 'nl': 'Live'},
    'deliveryAddress':  {'en': 'DELIVERY ADDRESS', 'fr': 'ADRESSE DE LIVRAISON', 'nl': 'LEVERINGSADRES'},
    'orderItems':       {'en': 'ORDER ITEMS', 'fr': 'ARTICLES COMMANDÉS', 'nl': 'BESTELARTIKELEN'},
    'deliveryConfirm':  {'en': 'DELIVERY CONFIRMATION', 'fr': 'CONFIRMATION DE LIVRAISON', 'nl': 'LEVERINGSBEVESTIGING'},
    'askPin':           {'en': 'Ask the customer for their 4-digit PIN to confirm handover.', 'fr': 'Demandez au client son code PIN à 4 chiffres pour confirmer.', 'nl': 'Vraag de klant om zijn 4-cijferige PIN ter bevestiging.'},
    'noPin':            {'en': 'No PIN required for this order.', 'fr': 'Aucun PIN requis pour cette commande.', 'nl': 'Geen PIN vereist voor deze bestelling.'},
    'incorrectPin':     {'en': 'Incorrect PIN. Ask the customer again.', 'fr': 'PIN incorrect. Redemandez au client.', 'nl': 'Onjuiste PIN. Vraag de klant opnieuw.'},
    'confirmDelivered': {'en': 'Confirm Delivered', 'fr': 'Confirmer la livraison', 'nl': 'Levering bevestigen'},

    // Success
    'delivered':        {'en': 'Delivered!', 'fr': 'Livré !', 'nl': 'Geleverd!'},
    'deliveredMsg':     {'en': 'Order successfully delivered.\nGreat work! 🚀', 'fr': 'Commande livrée avec succès.\nBravo ! 🚀', 'nl': 'Bestelling succesvol bezorgd.\nGoed gedaan! 🚀'},
    'backToDashboard':  {'en': 'Back to Dashboard', 'fr': 'Retour au tableau de bord', 'nl': 'Terug naar dashboard'},
    'back':             {'en': 'Back', 'fr': 'Retour', 'nl': 'Terug'},
  };
}
