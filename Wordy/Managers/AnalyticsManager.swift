//
//  AnalyticsManager.swift
//  Wordy
//
//  Created by user on 15.03.2024.
//

import Foundation
import FirebaseAnalytics
import FirebaseAuth

enum AnalyticsKeys: String { case method, type, id, subscription, referer, own, ai, email, apple, availability, sourcePage }

enum SignInMethod: String { case email, appleId }
enum LearnModuleAvailability: String { case DisabledBecauseLessThanRequiredCount, Available, DisabledBecauseNeedSubscription }
enum ChangeEmojiSourceScreenType: String { case CreateNewModulePage }
enum AddNewPhraseAvailability: String { case Available, DisabledBecauseMoreThanAllowedCount }
enum AddExampleSourceScreenType: String { case CreateNewPhrasePage, ModulePage }

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    private init() {}
    
    public func trackEvent(_ event: AnalyticsEvent) {
        var parameters: [String : Any]? = [:]
        
        switch event {
        case .signIn(let authService):
            parameters = [AnalyticsKeys.method.rawValue : authService.rawValue]
        case .tapOnLearnModule(let availability):
            parameters = [AnalyticsKeys.availability.rawValue : availability.rawValue]
        case .didTapOnChangeEmoji(let sourcePage):
            parameters = [AnalyticsKeys.sourcePage.rawValue : sourcePage.rawValue]
        case .didTapAddNewPhrase(let availability):
            parameters = [AnalyticsKeys.availability.rawValue : availability.rawValue]
        case .didTapAddExample(let sourcePage):
            parameters = [AnalyticsKeys.sourcePage.rawValue : sourcePage.rawValue]
        default:
            break
        }
        
//        guard TrackingManager.shared.isUserAllowed else { return }
        
        if let userId = Auth.auth().currentUser?.uid {
            Analytics.setUserID(userId)
        }
        
        DispatchQueue.global(qos: .default).async {
            Analytics.logEvent(event.eventName, parameters: parameters)
        }
    }
    
    enum AnalyticsEvent {
        case signIn(SignInMethod)
        case openedModule
        case registerViaEmail
        case skippedFirstOnboarding
        case skippedSecondPopupOnboarding
        case toggleNotificationButtonInsideModule
        case tapOnLearnModule(LearnModuleAvailability)
        case openNotificationSettingsScreen
        case tapOnGetProFromSettings
        case didTapLogout
        case openChangeLanguagePageFromSettings
        case openCreateNewModulePage
        case didTapOnChangeEmoji(ChangeEmojiSourceScreenType)
        case createdNewGroup
        case didTapOnCreateNewGroupPlusButton
        case didLongTappedForChangeGroup
        case didTapShareModule
        case didTapAddNewPhrase(AddNewPhraseAvailability)
        case didTapOnSpeechButton
        case didTapAddExample(AddExampleSourceScreenType)
        case didTapOnAutogeneratedTranslate
        case didTapOnAutogeneratedExample
        case openedModulesScreen
        case didTapDeleteAccount
        case sawPaywall
        case didTapOnOneYearPeriodBtn
        case didTapOnOneMonthPeriodBtn
        case didTapOnPaywallBuyBtn
        case didTapOnPaywallRestoreBtn
        case subscriptionBuyProcessFinishedWithError
        case subscriptionBuyProcessFinishedWithSuccess
        case didChangeColorTheme
        case openedEditGroupsPageFromSettings
        case finishFirstOnboarding
        case finishSecondPopupsOnboarding
        case openedSharedByOtherUsersSheet
        
        var eventName: String {
            switch self {
            case .openedModule: return "test_module_page_opened"
            case .signIn: return "sign_in"
            case .registerViaEmail: return "register_via_email"
            case .skippedFirstOnboarding: return "skipped_first_onboarding"
            case .skippedSecondPopupOnboarding: return "skipped_second_popup_onboarding"
            case .toggleNotificationButtonInsideModule: return "toggle_notification_button_inside_module"
            case .tapOnLearnModule: return "tap_on_learn_module"
            case .openNotificationSettingsScreen: return "open_notification_settings_screen"
            case .tapOnGetProFromSettings: return "tap_on_get_pro_from_settings"
            case .didTapLogout: return "did_tap_logout"
            case .openChangeLanguagePageFromSettings: return "open_change_language_page_from_settings"
            case .openCreateNewModulePage: return "open_create_new_module_page"
            case .didTapOnChangeEmoji: return "did_tap_on_change_emoji"
            case .createdNewGroup: return "created_new_group"
            case .didTapOnCreateNewGroupPlusButton: return "did_tap_on_create_new_group_plus_button"
            case .didLongTappedForChangeGroup: return "did_long_tapped_for_change_group"
            case .didTapShareModule: return "did_tap_share_module"
            case .didTapAddNewPhrase: return "did_tap_add_new_phrase"
            case .didTapOnSpeechButton: return "did_tap_on_speech_button"
            case .didTapAddExample: return "did_tap_add_example"
            case .didTapOnAutogeneratedTranslate: return "did_tap_on_autogenerated_translate"
            case .didTapOnAutogeneratedExample: return "did_tap_on_autogenerated_example"
            case .openedModulesScreen: return "opened_modules_screen"
            case .didTapDeleteAccount: return "did_tap_delete_account"
            case .sawPaywall: return "saw_paywall"
            case .didTapOnOneYearPeriodBtn: return "did_tap_on_one_year_period_btn"
            case .didTapOnOneMonthPeriodBtn: return "did_tap_on_one_month_period_btn"
            case .didTapOnPaywallBuyBtn: return "did_tap_on_paywall_buy_btn"
            case .didTapOnPaywallRestoreBtn: return "did_tap_on_paywall_restore_btn"
            case .subscriptionBuyProcessFinishedWithError: return "subscription_buy_process_finished_with_error"
            case .subscriptionBuyProcessFinishedWithSuccess: return "subscription_buy_process_finished_with_success"
            case .didChangeColorTheme: return "did_change_color_theme"
            case .openedEditGroupsPageFromSettings: return "opened_edit_groups_page_from_settings"
            case .finishFirstOnboarding: return "finish_first_onboarding"
            case .finishSecondPopupsOnboarding: return "finish_second_popups_onboarding"
            case .openedSharedByOtherUsersSheet: return "opened_shared_by_other_users_sheet"
            }
        }
    }
}
