
// will create an "agent" from different body parts
// NB: call Body.setTableParts() beforehand fore randomness
// NB: see AGENT_WIDTH and AGENT_HEIGHT for suppored image size
// WARNING: should call cleanup() when the agent is not needed
public class Agent {
  
  // The screen space occupied by agents is believed to be a certain size (in pixels).
  public static final int AGENT_WIDTH = 800;
  public static final int AGENT_HEIGHT = 850;

  // we need some spare parts to make a functional body
  private BodyPart head, eyes, mouth, heart;
  // is agent currently cleaning?
  private boolean cleaning = false;
  // what kind of man/female we are!
  public final Body.Genre genre;
  // which voice is selected?
  public final int voiceNumber;
  // randomize a bit voice pitch +/- 15 around 50 (espeak parameter)
  private final int PITCH_BASE = 75;
  private final int PITCH_RANGE = 10;
  public final int voicePitch;
  // Every elemet will be connected to it
  private PShape wholeBody;

  // use to check if mouth animation should be played in update()
  private AgentSpeak tts;

  // agent type, our independent variable
  public final Body.HR HRType;

  // for "human" type agent we want to recover hear rate
  private HeartManager hrMan;

  // Create the different parts -- by default HR is set to medium and no HeartManager
  Agent() {
    this(Body.HR.MEDIUM, null, null);
  }

  // Create the different parts.
  // HRType: which kind of beat we got for the heart
  // hrMan: tune heart rates with human type
  // trig: forward stim code sender to heart
  // TODO: could set to null if fot human type ; but not pretty. new constructor or  class instead.
  Agent(Body.HR HRType, HeartManager hrMan, Trigger trig) {
    this.HRType = HRType;
    this.hrMan = hrMan;  
    // Random 1 or 0 to get random male or female
    if (floor(random(2)) == 1) {
      this.genre = Body.Genre.MALE;
    } else {
      this.genre = Body.Genre.FEMALE;
    }
    // select one of the available voices
    voiceNumber = floor(random(TTS_NB_VOICES));
    voicePitch = floor(random(PITCH_BASE - PITCH_RANGE, PITCH_BASE + PITCH_RANGE + 1));
    // Create and position different parts
    head = new BodyPart(Body.Type.HEAD, this.genre);
    head.setPos(0, 0);
    // For eyes we got also some variability
    eyes = new BodyPart(Body.Type.EYES, this.genre);
    eyes.setPos(0, 0);
    eyes.setBPM(10);
    eyes.setBPMVariability(5);

    mouth = new BodyPart(Body.Type.MOUTH, this.genre);
    mouth.setPos(0, 0);
    // more complexe aminatiom for mouth, speed-up a bit
    mouth.setAnimationSpeed(50);

    // Special case for heart: will play a sound with each beat -- pass "hrMan" as a Trigger, *not* "trig", because in-between we want to compute fakeHR 
    heart = new BodyPart(Body.Type.HEART, Body.Genre.BOTH, "beat.wav", hrMan);
    // the original SVG is a bit too big
    // TODO: tune svg instead...
    heart.getPShape().scale(0.66);
    heart.setPos(500, 900);

    // deals with heart rate ; special case if human type and got HRManager
    if (HRType == Body.HR.HUMAN && hrMan != null) {
      heart.setBPM(hrMan.getHR());
    }
    // will be constant otherwise
    else {
      heart.setBPM(HRType.BPM);
      heart.setBPMVariability(HRType.variability);
    }
    // sharp beat
    heart.setAnimationSpeed(45);


    // time to add every part to the agent
    wholeBody = new PShape();
    wholeBody.addChild(head.getPShape());
    wholeBody.addChild(eyes.getPShape());
    wholeBody.addChild(mouth.getPShape());
    wholeBody.addChild(heart.getPShape());
  }

  // link to an instance of AgentSpeak for mouth animation
  public void setTTS(AgentSpeak tts) {
    this.tts = tts;
  }

  // will call recursively body parts + make mouth animate if speaking
  // halt if cleaning
  public void update() {
    // useless to update parts if cleanup() has been called: they won't do anything anymore
    if (cleaning) {
      return;
    }
    // animate mouth
    if (tts != null && tts.isSpeaking()) {
      mouth.animate();
    }

    // every part will update itself the visibility of the right frame if there's an animation to be played
    head.update();
    eyes.update();
    mouth.update();
    // tries to update HR if human type and got HRManager
    if (HRType == Body.HR.HUMAN && hrMan != null) {
      heart.setBPM(hrMan.getHR());
    }
    heart.update();
  }

  // access to master shape for transformations and drawing
  public PShape getPShape() {
    return wholeBody;
  }

  // will build an indenty from HR type, genre and every body parts details
  public String toString() {
    return HRType + "_" + genre + "-VOICE_" + voiceNumber + "-PITCH_" + voicePitch + "-" + head + "-" + eyes + "-" + mouth + "-" + heart;
  }

  // cleanup every body parts -- needed for audio stream. Return true when all parts are cleaned.
  // once called, will freeze agent (no more updates)
  public boolean cleanup() {
    println("Cleaning agent " + this);
    cleaning = true;
    // every part has to come clean
    return head.cleanup() && eyes.cleanup() && mouth.cleanup() && heart.cleanup();
  }
}

