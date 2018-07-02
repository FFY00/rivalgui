module rivalgui.app;

// 
// Rivalgui
// 
import rivalgui.util.ledcolor;

// 
// Std
// 

import std.stdio;
import std.file;
import std.experimental.logger;

// 
// Gtk
// 

// Types
import gtk.c.types;

// Top level
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Widget;
import gtk.Window;

// Contruct
import gtk.Builder;

// Elements
import gtk.Box;
import gtk.Button;
import gtk.ButtonBox;
import gtk.DrawingArea;
import gtk.Fixed;
import gtk.HeaderBar;
import gtk.Image;
import gtk.Label;
import gtk.MenuButton;
import gtk.Overlay;
import gtk.Popover;
import gtk.ProgressBar;
import gtk.Scale;
import gtk.SpinButton;
import gtk.Spinner;
import gtk.Switch;

// 
// Gio
// 

// Top level
import gio.Application : GApplication = Application;

// Elements
import gio.Menu : GMenu = Menu;
import gio.MenuItem : GMenuItem = MenuItem;

// 
// Cairo
// 
import cairo.Context;
import cairo.Surface;
import cairo.SvgSurface;

// 
// Rsvg
// 
import rsvg.Handle : RHandle = Handle;

// 
// Gdk
// 
import gdk.Cairo;
import gdkpixbuf.Pixbuf;
import gdkpixbuf.PixbufLoader;

/// Main application
class RivalGUI : Application
{

public:

    /// Constructor
    this()
    {
        ApplicationFlags flags = ApplicationFlags.FLAGS_NONE;
        super("org.aurorafoss.rivalgui", flags);
        this.window = null;
        this.addOnActivate(&onAppActivate);
    }

private:

    // 
    // Events
    // 

    void onAppActivate(GApplication app)
    {
        trace("Activate App Signal");
        if (!app.getIsRemote())
        {
            // Loads the UI files
            builder = new Builder();
            if(!builder.addFromResource("/org/aurorafoss/rivalgui/ui/MainWindow.ui"))
            {
                critical("Window resource cannot be found");
                return;
            }

            // Setup the app
            initElements();
            populateElements();
        }

        // Show
        this.window.present();
    }

    // 
    // Variable Declaration
    // 

    // Contruct
    Builder builder;

    // Elements

    /// Window
    ApplicationWindow window;
        // Header
        HeaderBar headerBar;
            MenuButton buttonMenu;
        // Content
        Box boxContent;
            // Main Content
            Box boxTop;
                // Image
                Box boxDevice;
                    // Left buttons
                    Box boxDeviceLeft;
                        Fixed fixeLeft;
                            Button buttonLeft;
                            Button buttonLed1;
                            Button buttonForward;
                            Button buttonBackward;
                            Button buttonLed0;
                    // Cairo image
                    Overlay overlayDevice;
                        DrawingArea drawingDevice;
                        Image imageMissing;
                        DrawingArea drawingLed0;
                        DrawingArea drawingLed1;
                        DrawingArea drawingLines;
                    // Right buttons
                    Box boxDeviceRight;
                        Fixed fixeRight;
                            Button buttonRight;
                            Button buttonWheel;
                            Button buttonResolution;
                // Sensitivity
                Box boxSensitivities;
                    // Sentitivity 1
                    Box boxSensitivity1;
                        Label labelSensitivity1;
                        SpinButton spinSensitivity1;
                        Scale sclaeSensitivity1;
                    // Sensitivity 2
                    Box boxSensitivity2;
                        Label labelSensitivity2;
                        SpinButton spinSensitivity2;
                        Scale sclaeSensitivity2;
                    // Report Rate
                    Box boxRate;
                        Label labelRate;
                        Box boxInnerRate;
                            ButtonBox buttonBoxRate;
                                Button buttonRate0;
                                Button buttonRate1;
                            Label labelRateHz;
            // Footer
            Box boxDown;
                // Live Preview
                Box boxLive;
                    Label labelLive;
                    Switch switchLive;
                // Write
                Box boxWrite;
                    Button buttonWrite;
                    Image imageWrite;
                    Spinner spinnerWrite;

        // Image
            // Source
            RHandle svg = null;
            // Line shapes
            Surface lineRight;
            Surface lineLeft;
            Surface lineWheel;
            Surface lineResolution;
            Surface lineForward;
            Surface lineBackward;
            Surface lineLed0;
            Surface lineLed1;
            // Led shapes
            Surface led0;
            Surface led1;
            // Led color
            LedColor colorLed0;
            LedColor colorLed1;

    // 
    // Initialization
    // 

    // Inits the builder defined elements
    void initElements()
    {
        // Top level
        window = cast(ApplicationWindow) builder.getObject("window");
        window.setApplication(this);

        // Elements
        buttonMenu = cast(MenuButton) builder.getObject("buttonMenu");

        drawingDevice = cast(DrawingArea) builder.getObject("drawingDevice");
        imageMissing = cast(Image) builder.getObject("imageMissing");
        drawingLed0 = cast(DrawingArea) builder.getObject("drawingLed0");
        drawingLed1 = cast(DrawingArea) builder.getObject("drawingLed1");
        drawingLines = cast(DrawingArea) builder.getObject("drawingLines");
    }

    // Sets up the gui structure
    void populateElements()
    {
        // Led colors
        colorLed0 = new LedColor(0, 0, 0);
        colorLed1 = new LedColor(0, 0, 0);

        // Setup menu
        createMenuPopover(buttonMenu);

        // Render the image
        setupDrawingDevice();

        // Test
        updateLed0(127, 0, 0);
        updateLed1(127, 63, 127);
    }

    // 
    // Custom elements
    // 

    // Popover for buttonMenu
    void createMenuPopover(ref MenuButton parent)
    {
        GMenu menu = new GMenu;

        // Only 1 selection. For now...
        menu.appendItem(new GMenuItem("Settings", null));
        menu.appendItem(new GMenuItem("About", null));

        parent.setPopover(new Popover(cast(Widget) parent, menu));
    }

    // Setup device image
    void setupDrawingDevice()
    {
        drawingDevice.addOnDraw(&drawCairoDevice);
        drawingLed0.addOnDraw(&drawCairoLed0);
        drawingLed1.addOnDraw(&drawCairoLed1);
        drawingLines.addOnDraw(&drawCairoLines);

        string[] files =
            ["/usr/share/libratbag/gnome/steelseries-rival310.svg",
                "/usr/local/share/libratbag/gnome/steelseries-rival310.svg",
                "~/.local/share/libratbag/gnome/steelseries-rival310.svg"];
        // Find the image
        foreach(f ; files)
        {
            if(f.exists())
            {
                svg = new RHandle(f);
                return;
            }
        }

        imageMissing.setVisible(true);
    }

    // 
    // Handlers
    // 

    bool drawCairoDevice(Scoped!Context cr, Widget widget)
    {
        if(svg && svg.hasSub("#Device"))
        {
            cr.setSourcePixbuf(svg.getPixbufSub("#Device"), 0, 0);
            cr.paint();
        }

        return true;
    }

    bool drawCairoLed0(Scoped!Context cr, Widget widget)
    {
        // Get the shape
        if(!led0)                                                    
            led0 = surfaceCreateFromPixbuf(svg.getPixbufSub("#led0"), 1, null); // scale, window

        // Set color
        // Make the backround white first
        cr.setSourceRgb(1, 1, 1);
        cr.maskSurface(led0, 0, 0);
        cr.setSourceRgba(colorLed0.r, colorLed0.g, colorLed0.b, colorLed0.a);
        cr.maskSurface(led0, 0, 0);

        return true;
    }

    bool drawCairoLed1(Scoped!Context cr, Widget widget)
    {
        // Get the shape
        if(!led1)
            led1 = surfaceCreateFromPixbuf(svg.getPixbufSub("#button2"), 1, null); // scale, window

        // Set color
        cr.setSourceRgba(colorLed1.r, colorLed1.g, colorLed1.b, colorLed1.a);
        cr.maskSurface(led1, 0, 0);

        return true;
    }

    bool drawCairoLines(Scoped!Context cr, Widget widget)
    {
        // Get the shape
        if(!lineRight)
            lineRight = surfaceCreateFromPixbuf(svg.getPixbufSub("#button1-path"), 1, null); // scale, window

        if(!lineLeft)
            lineLeft = surfaceCreateFromPixbuf(svg.getPixbufSub("#button0-path"), 1, null); // scale, window

        if(!lineWheel)
            lineWheel = surfaceCreateFromPixbuf(svg.getPixbufSub("#button2-path"), 1, null); // scale, window

        if(!lineResolution)
            lineResolution = surfaceCreateFromPixbuf(svg.getPixbufSub("#button5-path"), 1, null); // scale, window

        if(!lineForward)
            lineForward = surfaceCreateFromPixbuf(svg.getPixbufSub("#button4-path"), 1, null); // scale, window

        if(!lineBackward)
            lineBackward = surfaceCreateFromPixbuf(svg.getPixbufSub("#button3-path"), 1, null); // scale, window

        if(!lineLed0)
            lineLed0 = surfaceCreateFromPixbuf(svg.getPixbufSub("#led0-path"), 1, null); // scale, window

        if(!lineLed1)
            lineLed1 = surfaceCreateFromPixbuf(svg.getPixbufSub("#led1-path"), 1, null); // scale, window

        // Right
        cr.setSourceSurface(lineRight, 0, 0);
        cr.paint();

        // Left
        cr.setSourceSurface(lineLeft, 0, 0);
        cr.paint();

        // Wheel
        cr.setSourceSurface(lineWheel, 0, 0);
        cr.paint();

        // Resolution
        cr.setSourceSurface(lineResolution, 0, 0);
        cr.paint();

        // Forward
        cr.setSourceSurface(lineForward, 0, 0);
        cr.paint();

        // Backward
        cr.setSourceSurface(lineBackward, 0, 0);
        cr.paint();

        // Led 0
        cr.setSourceRgb(0, 0.35, 1);
        cr.maskSurface(lineLed0, 0, 0);

        // Led 1
        cr.setSourceRgb(0, 0.35, 1);
        cr.maskSurface(lineLed1, 0, 0);

        return true;
    }

    // 
    // Functionality
    // 

    /// Re-draw led 0
    void updateLed0()
    {
        GtkAllocation area;
        drawingLed0.getAllocation(area);
        drawingLed0.queueDrawArea(area.x, area.y, area.width, area.height);
        drawingLed0.setVisible(true);
    }

    /// Change led 0 color and re-draw
    void updateLed0(ubyte r, ubyte g, ubyte b)
    {
        colorLed0.setColor(r, g, b);
        updateLed0();
    }

    /// Re-draw led 1
    void updateLed1()
    {
        GtkAllocation area;
        drawingLed1.getAllocation(area);
        drawingLed1.queueDrawArea(area.x, area.y, area.width, area.height);
        drawingLed1.setVisible(true);
    }

    /// Change led 1 color and re-draw
    void updateLed1(ubyte r, ubyte g, ubyte b)
    {
        colorLed1.setColor(r, g, b);
        updateLed1();
    }

}