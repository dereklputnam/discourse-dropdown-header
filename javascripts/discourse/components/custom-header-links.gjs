import { tracked } from "@glimmer/tracking";
import Component from "@ember/component";
import { fn, hash } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import CustomHeaderLink from "./custom-header-link";
import CustomIcon from "./custom-icon";

const NARROW_MQ = "(max-width: 925px)";

export default class CustomHeaderLinks extends Component {
  @service siteSettings;
  @service site;

  @tracked _isNarrow = window.matchMedia(NARROW_MQ).matches;
  @tracked showLinks =
    !this.site.mobileView && !window.matchMedia(NARROW_MQ).matches;

  get isNarrowView() {
    return this.site.mobileView || this._isNarrow;
  }

  didInsertElement() {
    super.didInsertElement(...arguments);
    this._mq = window.matchMedia(NARROW_MQ);
    this._mqHandler = (e) => {
      this._isNarrow = e.matches;
      if (!this.site.mobileView) {
        this.showLinks = !e.matches;
      }
    };
    this._mq.addEventListener("change", this._mqHandler);
  }

  willDestroyElement() {
    super.willDestroyElement(...arguments);
    this._mq?.removeEventListener("change", this._mqHandler);
  }

  @action
  toggleHeaderLinks() {
    this.showLinks = !this.showLinks;

    if (this.showLinks) {
      document.body.classList.add("dropdown-header-open");
    } else {
      document.body.classList.remove("dropdown-header-open");
    }
  }

  get headerLinks() {
    return JSON.parse(settings.header_links);
  }

  get singleParentDropdownLinks() {
    if (!this.isNarrowView) {
      return null;
    }

    if (this.headerLinks.length !== 1) {
      return null;
    }

    const parent = this.headerLinks[0];
    const allDropdownItems = settings.dropdown_links
      ? JSON.parse(settings.dropdown_links)
      : [];
    const children = allDropdownItems.filter(
      (d) => d.headerLinkId === parent.id
    );

    return children.length > 0 ? children : null;
  }

  @action
  redirectToUrl(item, event) {
    if (this.isNarrowView) {
      this.toggleHeaderLinks();
    }

    if (item.newTab) {
      window.open(item.url, "_blank");
    } else {
      DiscourseURL.routeTo(item.url);
    }

    event.stopPropagation();
  }

  <template>
    <nav
      class={{concatClass
        "custom-header-links"
        (if @outletArgs.minimized "scrolling")
      }}
    >
      {{#if this.isNarrowView}}
        <span class="btn-custom-header-dropdown-mobile">
          <DButton
            @icon="square-caret-down"
            @title={{i18n "custom_header.discord"}}
            @action={{this.toggleHeaderLinks}}
          />
        </span>
      {{/if}}

      {{#if this.showLinks}}
        <ul
          class="top-level-links"
          {{(if
            this.isNarrowView
            (modifier
              closeOnClickOutside
              this.toggleHeaderLinks
              (hash target=this.element)
            )
          )}}
        >
          {{#if this.singleParentDropdownLinks}}
            {{#each this.singleParentDropdownLinks as |item|}}
              <li
                class="custom-header-link with-url"
                title={{item.title}}
                role="button"
                {{on "click" (fn this.redirectToUrl item)}}
              >
                <CustomIcon @icon={{item.icon}} />
                <span class="custom-header-link-title">{{item.title}}</span>
              </li>
            {{/each}}
          {{else}}
            {{#each this.headerLinks as |item|}}
              <CustomHeaderLink
                @item={{item}}
                @toggleHeaderLinks={{this.toggleHeaderLinks}}
              />
            {{/each}}
          {{/if}}
        </ul>
      {{/if}}
    </nav>
  </template>
}
