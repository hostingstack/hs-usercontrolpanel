var Controlpanel = {};

Controlpanel.AppInstall = {
  locations_attributes: [],

  createDialog: function(url, title, onload) {
    var onload = onload || function(x) {};
    
    var dialog = $('<div class="loading"></div>').dialog({width: 600,
        height: 450,
        modal: true,
        position: ['center', 50],
        draggable: false,
        resizable: false,
        title: title,
        close: function() { var f = function() { dialog.dialog('destroy'); dialog.remove();}; setTimeout(f, 0); }
      });
   
    var ajaxify_form = function(el) {
      $(el).find('form').each(function() {
        var frm = el;
        $(this).ajaxForm({target:$(this).closest('.ui-dialog-content'), success: function(r) {ajaxify_form(this); onload(r,dialog);},
                          beforeSubmit: function() { $(frm).find('input[type=submit]').addClass('loading'); },
          });
      });
    };

    dialog.load(url, function(r) { onload(r, dialog); ajaxify_form(this); dialog.removeClass('loading'); });
    return dialog;
  },
  
  initialize: function() {
    $('.radio input[type="radio"]:checked').each(function(i,e) {
        e = $(e).closest('.radio')[0];
        var s = e.id ? '#'+e.id : '';
        $(e).addClass('selected');
        $(e).siblings('.radio'+s).removeClass('selected');
      });
    $('.radio').bind('click', function(e) {
        $(this).find('input[type="radio"]').click();
      });
    $('.radio input[type="radio"]').bind('click', function(e) {
        $(this).closest('.radio').addClass('selected');
        var s = '';
        if($(this).closest('.radio')[0].id) {
          s = '#'+$(this).closest('.radio')[0].id;
        }
        $(this).closest('.radio').siblings('.radio'+s).removeClass('selected');
        e.stopPropagation();
      });

    $('input[type=text]').not('.noclear').autoclear();

    if($('body.routes.index').length>0) {
      Controlpanel.AppInstall.initialize_settings();
    }

    var t = $('.content .settings #functiontabs')

    $('.settingscontainer form').each(function(i,e) {
      var el = $(e).closest('.settingscontainer')[0] || e;
      el = el.parentNode;
      $(e).ajaxForm({target: el, success: Controlpanel.AppInstall.initialize});
    });

    $('.architecture .service_overview .services .service, .architecture .service_overview .services .serviceoverride').bind("click", function(event) {
      $(".descriptions .service").removeClass("show");
      $(".architecture .service_overview .services .service, .architecture .service_overview .services .serviceoverride").removeClass("selected");
      $(".descriptions .service[for="+this.id+"]").addClass("show");
      $(this).addClass("selected");
    });

    $(document).delegate('.replace_here form[data-remote]', 'ajax:before', function(evt,data) { $(this).addClass('loading'); });
    $(document).delegate('.replace_here form[data-remote]', 'ajax:success', function(evt,data) { var p = $(this).closest('.replace_here').replaceWith(data); });
    $(document).delegate('.append_here form[data-remote][data-remote-append]', 'ajax:before', function(evt,data) { $(this).addClass('loading'); });
    $(document).delegate('form[data-remote][data-remote-append].append_before ', 'ajax:before', function(evt,data) { $(this).addClass('loading'); });
    $(document).delegate('.append_here form[data-remote][data-remote-append]', 'ajax:success', function(evt, data) { $(this).removeClass('loading'); this.reset(); var p = $(this).closest('.append_here'); p.append(data); });
    $(document).delegate('form[data-remote][data-remote-append].append_before', 'ajax:success', function(evt, data) { $(this).removeClass('loading'); this.reset(); $(this).before(data); });

    $(document).delegate('.replace_here input[data-autosubmit]', 'change', function(evt, data) { var obj = {}; obj[this.name] = this.value; $(this).addClass('loading'); $(this).attr('disabled','disabled'); $(this).closest('.replace_here').load($(this).data('autosubmit'), obj); });

    $(document).delegate('a.delete.periodictask,a.delete.command','ajax:before', function() { $(this).addClass('loading'); });
    $(document).delegate('a.delete.periodictask','ajax:success', function(xhr, data) { var prnt = $(this).closest('.replace_here'); $(this).hide(); prnt.addClass('deleted'); setTimeout(function() { prnt.remove(); }, 500); });
    $(document).delegate('a.delete.command','ajax:complete', function() { var prnt = $(this).closest('div.command'); prnt.remove(); });
    $(document).delegate('input.edit-inline','blur', function() { var el = $(this); var obj = {'_method': 'put'}; obj[$(this).attr('name')] = $(this).attr('value'); $(this).removeClass('display'); $(this).addClass('submitting'); $.post($(this).data('submit'), obj, function() { console.log('success.'); el.removeClass('submitting'); el.addClass('display'); }); });

    var timer = null;
    var elements_to_submit = [];

    var submit_elements = function() {
      var ets = elements_to_submit;
      elements_to_submit = [];
      for(var i=0;i<ets.length;i++) {
        $(ets[i]).trigger('change');
      }
    }

    var change_field = function(btn, delta) {
      clearTimeout(timer);
      var p = $(btn).closest('.spinner').find('input')[0];
      if($(p).attr('disabled')) {
        return;
      }
      p.value = Number(p.value)+delta;
      if(elements_to_submit.indexOf(p)<0) {
        elements_to_submit.push(p);
      }
      timer = setTimeout(submit_elements, 500);
    };

    $(document).delegate('.spinner .updown .up', 'click', function(evt, data) { change_field(this, 1); return false; });
    $(document).delegate('.spinner .updown .down', 'click', function(evt, data) { change_field(this, -1); return false; });
  },

  initialize_settings: function() {
    var dialog = $('div.settings');
    Controlpanel.AppInstall.locations_attributes = [];
      
    var warning = $('#route_domain_name_warning').html('Verify your ownership of this domain.');
    var options = [];
    var submitbtn = dialog.find('#route_submit');
    dialog.find('.new_route').unbind('ajax:beforeSend');
    dialog.find('.new_route').bind('ajax:beforeSend', function() {
      $(this).addClass('loading');
    });
    dialog.find('.new_route').unbind('ajax:success');
    dialog.find('.new_route').bind('ajax:success', function(xhr, data, status) {
      data = $(data);
      Controlpanel.AppInstall.bind_settings_location_event_handlers(data);
      dialog.find('.locations').append(data);
      $(this).removeClass('loading');
      $(this).removeClass('show');
      $(this)[0].reset();
    });
    Controlpanel.AppInstall.bind_settings_location_event_handlers(dialog.find('.location'));

    dialog.find('.deleteapp a').unbind('ajax:success');
    dialog.find('.deleteapp a').bind('ajax:success', function() {
        dialog.dialog('close');
        dialog.remove();
        app.addClass('deleted');
    });
    
    var verifybtn = dialog.find('.verify');

    var update_buttons = function(override_focus) {
      var domain_known = options.indexOf(dialog.find("#route_domain_name")[0].value)>=0;
      var any_input = dialog.find("#route_domain_name")[0].value.trim().length>0;
      submitbtn.attr('disabled',any_input?'':'disabled');
      dialog.find('#route_domain_unknown')[any_input&&!domain_known?'show':'hide']();
      dialog.find('.errors').text('');
      if(!domain_known && override_focus)
        verifybtn.find('input').focus();
    };
    dialog.find("#route_domain_name").unbind('click');
    dialog.find("#route_domain_name").bind('click', function() { $(this).autocomplete("search");  });
    dialog.find("#route_domain_name").unbind('blur');
    dialog.find("#route_domain_name").bind('blur', function() { update_buttons(true); });
    dialog.find("#route_domain_name").bind('keydown');
    dialog.find("#route_domain_name").bind('keydown', function() { setTimeout(function() { update_buttons(); },0); });
    $.ajax({url: '/domains/list/', type: 'get', success: function(data, textStatus, jqXHR) {
        for(var i=0;i<data.length;i++) {
          options.push(data[i].domain.name);
        }
        dialog.find("#route_domain_name").autocomplete({source: options, minLength: 0, select: function() { setTimeout(update_buttons, 0); }});
        dialog.find("#route_domain_name").unbind('focus');
        dialog.find("#route_domain_name").bind('focus', function() {dialog.find("#route_domain_name").autocomplete('search');});
      }});
    dialog.find('[data-refresh-url]').unbind('refresh');
    dialog.find('[data-refresh-url]').bind('refresh', function() {
        var e = $(this);
        e.addClass('loading');
        e.load(e.data('refresh-url')+' #refresh', function() { e.removeClass('loading'); Controlpanel.AppInstall.bind_settings_location_event_handlers(e); });
        });
  },
  
  bind_settings_location_event_handlers: function(selector) {
    selector.find('.delete').unbind('ajax:beforeSend');
    selector.find('.delete').bind('ajax:beforeSend', function() {
      $(this).closest('.location').addClass('loading');
    });
    selector.find('.delete').unbind('ajax:success');
    selector.find('.delete').bind('ajax:success', function() {
      $(this).closest('.location').remove();
    });
    selector.find('.dns').unbind('click');
    selector.find('.dns').bind('click', function(e) {
      var el = this;

      var onload = function() {
      };

      var dialog = Controlpanel.AppInstall.createDialog(this.href,'DNS: '+$(el).siblings('.url').find('a').attr('href'));
      dialog.bind('dialogclose', function() {
        var e = $(el);
        var p = e.closest('.location');
        p.siblings('[data-domain='+p.data('domain')+']').andSelf().trigger('refresh');
      });
      e.stopPropagation();
      e.preventDefault();
    });
  },

};

Controlpanel.domain_deleted = function(domain_id) {
  $('#domain_'+domain_id).each(function(i,e) {e.className+=' deleted'});
};

Controlpanel.verify_dns = function(app_id, route_id, initial) {
  if(initial) {
    Controlpanel.verify_dns_dialog  = Controlpanel.AppInstall.createDialog('/apps/'+app_id+'/routes/'+route_id+'/verify_dns','Check Location');
    return;
  }
  var d = Controlpanel.verify_dns_dialog;
  d.find('.location_verify').addClass('loading');

  $.post('/apps/'+app_id+'/routes/'+route_id+'/verify_dns', {}, function(data) {
	var success = data.dns_verify_last_successful;
	d.find('.location_verify').removeClass('loading');
	d.find('#location_verify_result').removeClass('success');
	d.find('#location_verify_result').removeClass('nosuccess');
	d.find('#location_verify_result').addClass(success?'success':'nosuccess');
	d.find('#location_verify_result .elaborate').text(data.dns_verify_last_log);
	d.find('.location_verify .show_details').show();
      });
};

Controlpanel.verify_dns_details = function() {
  $('#location_verify_result .elaborate').addClass('show');
};

Controlpanel.Deployment = {
  'drain_status': function(drain_url) {
    $.getJSON(drain_url, function(data) {
      state = data['message'];

      if (state == "error" || state == "finished") {
        window.location.reload();
      } else {
        human_state_translator = {
          'build': 'Building/updating virtual machine...',
          'deploy': 'Copying virtual machine to app hosts...',
          'publishing': 'Updating HTTP gateways...',
          'cleanup': 'Removing old deployments...',
          'pending': 'Please wait...'}
        
        $('#deployment_state h2 span').html(human_state_translator[state] || state);
        if (data['logs']) {
          $('#deployment_logs').append(data['logs'].replace(/\n/g, "<br />"));
          $('#deployment_logs').scrollTop(1000000);
        }
        
        setTimeout(function() {
          Controlpanel.Deployment.drain_status(drain_url);
        }, 500);
      }
    });
  }
};

$(document).ready(Controlpanel.AppInstall.initialize);
